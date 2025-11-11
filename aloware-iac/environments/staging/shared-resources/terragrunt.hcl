terraform {
  source = "${get_repo_root()}/../../aloware-infraestructure-modules//composite-modules/shared-resources"
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

inputs = {
  env            = local.env
  aws_account_id = local.aws_account_id
  aws_region     = local.aws_region
  
  # S3 Buckets for shared resources
  bucket_prefix = "aloware-prod"
  
  # Lifecycle rules for S3
  lifecycle_rules = [
    {
      id = "DeleteOldVersions"
      noncurrent_version_expiration = [
        {
          noncurrent_days           = 90
          newer_noncurrent_versions = 3
        }
      ]
      status = "Enabled"
    }
  ]
  
  # VPC Endpoints for cost optimization and security
  vpc_endpoints      = ["s3", "ecr.api", "ecr.dkr", "rds", "secretsmanager", "ssm"]
  create_s3_endpoint = true
  
  # SNS notifications
  sns_emails = [
    "devops@aloware.com"  # Update with actual production notification email
  ]
  
  # Production tags
  tags = {
    Project             = "Aloware"
    Environment         = "production"
    ManagedBy           = "Terraform"
    CostCenter          = "Engineering"
    Compliance          = "Required"
    BackupPolicy        = "Required"
    DataClassification  = "Confidential"
  }
}
