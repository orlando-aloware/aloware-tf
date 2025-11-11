terraform {
  source = "${get_repo_root()}/../../aloware-infraestructure-modules//composite-modules/storage"
}

include "root" {
  path = find_in_parent_folders("common.hcl")
}

locals {
  env_vars       = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  aws_account_id = local.env_vars.locals.aws_account_id
  env            = local.env_vars.locals.env
  region_vars    = read_terragrunt_config("region.hcl")
  aws_region     = local.region_vars.locals.aws_region
  config         = yamldecode(file("${get_repo_root()}/aloware-iac/config/production.yaml"))
}

dependency "shared_resources" {
  config_path = "../shared-resources"
  mock_outputs = {
    kms_key_id = "mock-kms-key"
  }
}

inputs = {
  # S3 Buckets for production
  s3_buckets = {
    # Talk2 frontend assets (Vue.js/Quasar build)
    talk2-frontend = {
      bucket_name        = "aloware-prod-talk2-frontend"
      versioning_enabled = true
      encryption_type    = "kms"
      kms_key_id         = dependency.shared_resources.outputs.kms_key_id
      
      lifecycle_rules = [
        {
          id     = "delete-old-versions"
          status = "Enabled"
          noncurrent_version_expiration = {
            days = 90
          }
        }
      ]
      
      cors_rules = [
        {
          allowed_headers = ["*"]
          allowed_methods = ["GET", "HEAD"]
          allowed_origins = ["https://app.aloware.com", "https://*.aloware.com"]
          expose_headers  = ["ETag"]
          max_age_seconds = 3000
        }
      ]
      
      public_access_block = {
        block_public_acls       = false # CloudFront needs access
        block_public_policy     = false
        ignore_public_acls      = false
        restrict_public_buckets = false
      }
    }
    
    # Application file uploads (recordings, attachments, etc.)
    application-uploads = {
      bucket_name        = "aloware-prod-uploads"
      versioning_enabled = true
      encryption_type    = "kms"
      kms_key_id         = dependency.shared_resources.outputs.kms_key_id
      
      lifecycle_rules = [
        {
          id     = "transition-to-glacier"
          status = "Enabled"
          transitions = [
            {
              days          = 90
              storage_class = "GLACIER"
            },
            {
              days          = 365
              storage_class = "DEEP_ARCHIVE"
            }
          ]
        }
      ]
      
      public_access_block = {
        block_public_acls       = true
        block_public_policy     = true
        ignore_public_acls      = true
        restrict_public_buckets = true
      }
    }
    
    # Backups and exports
    backups = {
      bucket_name        = "aloware-prod-backups"
      versioning_enabled = true
      encryption_type    = "kms"
      kms_key_id         = dependency.shared_resources.outputs.kms_key_id
      
      lifecycle_rules = [
        {
          id     = "expire-old-backups"
          status = "Enabled"
          expiration = {
            days = 90
          }
        }
      ]
      
      public_access_block = {
        block_public_acls       = true
        block_public_policy     = true
        ignore_public_acls      = true
        restrict_public_buckets = true
      }
    }
    
    # Logs (application, access, CloudTrail, etc.)
    logs = {
      bucket_name        = "aloware-prod-logs"
      versioning_enabled = true
      encryption_type    = "kms"
      kms_key_id         = dependency.shared_resources.outputs.kms_key_id
      
      lifecycle_rules = [
        {
          id     = "transition-logs"
          status = "Enabled"
          transitions = [
            {
              days          = 30
              storage_class = "STANDARD_IA"
            },
            {
              days          = 90
              storage_class = "GLACIER"
            }
          ]
          expiration = {
            days = 365
          }
        }
      ]
      
      public_access_block = {
        block_public_acls       = true
        block_public_policy     = true
        ignore_public_acls      = true
        restrict_public_buckets = true
      }
    }
  }
  
  # ECR Repositories for container images
  ecr_repositories = {
    # API Core (Laravel/PHP)
    api-core = {
      repository_name      = "aloware/api-core"
      image_tag_mutability = "IMMUTABLE" # Production images should be immutable
      
      encryption_configuration = {
        encryption_type = "KMS"
        kms_key         = dependency.shared_resources.outputs.kms_key_id
      }
      
      image_scanning_configuration = {
        scan_on_push = true
      }
      
      lifecycle_policy = jsonencode({
        rules = [
          {
            rulePriority = 1
            description  = "Keep last 30 production images"
            selection = {
              tagStatus     = "tagged"
              tagPrefixList = ["prod-"]
              countType     = "imageCountMoreThan"
              countNumber   = 30
            }
            action = {
              type = "expire"
            }
          },
          {
            rulePriority = 2
            description  = "Remove untagged images after 7 days"
            selection = {
              tagStatus   = "untagged"
              countType   = "sinceImagePushed"
              countUnit   = "days"
              countNumber = 7
            }
            action = {
              type = "expire"
            }
          }
        ]
      })
    }
    
    # Talk2 (if containerized components exist)
    talk2 = {
      repository_name      = "aloware/talk2"
      image_tag_mutability = "IMMUTABLE"
      
      encryption_configuration = {
        encryption_type = "KMS"
        kms_key         = dependency.shared_resources.outputs.kms_key_id
      }
      
      image_scanning_configuration = {
        scan_on_push = true
      }
      
      lifecycle_policy = jsonencode({
        rules = [
          {
            rulePriority = 1
            description  = "Keep last 30 production images"
            selection = {
              tagStatus     = "tagged"
              tagPrefixList = ["prod-"]
              countType     = "imageCountMoreThan"
              countNumber   = 30
            }
            action = {
              type = "expire"
            }
          }
        ]
      })
    }
  }
  
  # Production tags
  tags = {
    Module           = "storage"
    Tier             = "data"
    Criticality      = "high"
    DisasterRecovery = "required"
    BackupPolicy     = "required"
    MonitoringLevel  = "enhanced"
    DataRetention    = "policy-based"
  }
}
