# !!!!!!!!!!!!!!!!!!!!!
# DONOT MAKE ANY CHANGES TO THIS FILE WITHOUT TEAM APPROVAL
# THIS FILE AFFECTS ALL ENVIRONMENTS
# !!!!!!!!!!!!!!!!!!!!!

locals {
  # Automatically load environment-level variables
  env_vars       = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  aws_account_id = local.env_vars.locals.aws_account_id
  env            = local.env_vars.locals.env
  aws_region     = local.env_vars.locals.aws_region
  
  # Common tags applied to all resources
  common_tags = {
    Environment   = local.env
    ManagedBy     = "Terragrunt"
    Organization  = "Aloware"
    CostCenter    = "Engineering"
    Compliance    = "SOC2"
    BackupPolicy  = local.env == "prod" ? "daily" : "weekly"
  }
}

# Generate AWS provider block for all modules
generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  
  allowed_account_ids = ["${local.aws_account_id}"]
  
  default_tags {
    tags = {
      Environment  = "${local.env}"
      ManagedBy    = "Terragrunt"
      Organization = "Aloware"
    }
  }
}

# US East 1 provider for CloudFront, ACM certificates, etc.
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  
  allowed_account_ids = ["${local.aws_account_id}"]
  
  default_tags {
    tags = {
      Environment  = "${local.env}"
      ManagedBy    = "Terragrunt"
      Organization = "Aloware"
    }
  }
}

terraform {
  required_version = ">= 1.8.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in S3
remote_state {
  backend = "s3"
  
  config = {
    encrypt        = true
    bucket         = "aloware-${local.env}-${local.aws_account_id}-${local.aws_region}-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "aloware-${local.env}-terraform-state-lock"
    
    # Enable state locking
    skip_metadata_api_check     = false
    skip_credentials_validation = false
    
    # S3 bucket tags
    s3_bucket_tags = {
      Name         = "aloware-${local.env}-terraform-state"
      Environment  = local.env
      ManagedBy    = "Terragrunt"
      Purpose      = "TerraformState"
    }
    
    # DynamoDB table tags
    dynamodb_table_tags = {
      Name         = "aloware-${local.env}-terraform-state-lock"
      Environment  = local.env
      ManagedBy    = "Terragrunt"
      Purpose      = "TerraformStateLock"
    }
  }
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Global inputs available to all modules
inputs = {
  environment    = local.env
  aws_account_id = local.aws_account_id
  aws_region     = local.aws_region
  common_tags    = local.common_tags
  
  # Organization settings
  org_name       = "aloware"
  domain_name    = local.env == "prod" ? "aloware.com" : (local.env == "staging" ? "alostaging.com" : "alodev.org")
}
