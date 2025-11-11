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
  aws_region     = local.env_vars.locals.aws_region
}

inputs = {
  # S3 Buckets
  buckets = {
    # Terraform state bucket (managed separately, just referenced here)
    terraform_state = {
      name = "aloware-${local.env}-${local.aws_account_id}-${local.aws_region}-terraform-state"
      versioning = {
        enabled = true
      }
      lifecycle_rules = [
        {
          id      = "delete-old-versions"
          enabled = true
          noncurrent_version_expiration = {
            days = 90
          }
        }
      ]
      server_side_encryption = {
        rule = {
          apply_server_side_encryption_by_default = {
            sse_algorithm = "AES256"
          }
        }
      }
    }
    
    # Application artifacts bucket
    artifacts = {
      name = "aloware-${local.env}-${local.aws_account_id}-${local.aws_region}-artifacts"
      versioning = {
        enabled = true
      }
      lifecycle_rules = [
        {
          id      = "delete-old-artifacts"
          enabled = true
          expiration = {
            days = local.env == "production" ? 90 : 30
          }
        }
      ]
    }
    
    # Application logs bucket
    logs = {
      name = "aloware-${local.env}-${local.aws_account_id}-${local.aws_region}-logs"
      versioning = {
        enabled = false
      }
      lifecycle_rules = [
        {
          id      = "delete-old-logs"
          enabled = true
          expiration = {
            days = local.env_vars.locals.log_retention_days
          }
        }
      ]
    }
    
    # Application data bucket
    application_data = {
      name = "aloware-${local.env}-${local.aws_account_id}-${local.aws_region}-app-data"
      versioning = {
        enabled = local.env == "production"
      }
      cors_rules = [
        {
          allowed_headers = ["*"]
          allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
          allowed_origins = ["https://*.${local.env == "production" ? "aloware.com" : (local.env == "staging" ? "alostaging.com" : "alodev.org")}"]
          expose_headers  = ["ETag"]
          max_age_seconds = 3000
        }
      ]
    }
    
    # Backup bucket
    backups = {
      name = "aloware-${local.env}-${local.aws_account_id}-${local.aws_region}-backups"
      versioning = {
        enabled = true
      }
      lifecycle_rules = [
        {
          id      = "transition-to-glacier"
          enabled = local.env == "production"
          transitions = [
            {
              days          = 30
              storage_class = "GLACIER"
            }
          ]
          expiration = {
            days = local.env == "production" ? 365 : 90
          }
        }
      ]
    }
  }
  
  # ECR Repositories
  ecr_repositories = [
    {
      name                 = "api-core/api"
      image_tag_mutability = "MUTABLE"
      scan_on_push        = true
      
      lifecycle_policy = jsonencode({
        rules = [
          {
            rulePriority = 1
            description  = "Keep last 30 images"
            selection = {
              tagStatus     = "tagged"
              tagPrefixList = ["v", "app", "pr-"]
              countType     = "imageCountMoreThan"
              countNumber   = 30
            }
            action = {
              type = "expire"
            }
          }
        ]
      })
    },
    {
      name                 = "api-core/queue"
      image_tag_mutability = "MUTABLE"
      scan_on_push        = true
      
      lifecycle_policy = jsonencode({
        rules = [
          {
            rulePriority = 1
            description  = "Keep last 30 images"
            selection = {
              tagStatus     = "tagged"
              tagPrefixList = ["v", "app", "pr-"]
              countType     = "imageCountMoreThan"
              countNumber   = 30
            }
            action = {
              type = "expire"
            }
          }
        ]
      })
    },
    {
      name                 = "aloware-base-images/php-fpm"
      image_tag_mutability = "MUTABLE"
      scan_on_push        = true
      
      lifecycle_policy = jsonencode({
        rules = [
          {
            rulePriority = 1
            description  = "Keep last 10 images"
            selection = {
              tagStatus   = "any"
              countType   = "imageCountMoreThan"
              countNumber = 10
            }
            action = {
              type = "expire"
            }
          }
        ]
      })
    }
  ]
  
  # Tags
  tags = {
    Module = "storage"
    Tier   = "infrastructure"
  }
}
