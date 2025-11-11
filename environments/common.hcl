# !!!!!!!!!!!!!!!!!!!!!
# DONOT MAKE ANY CHANGES TO THIS FILE, IT AFFECTS ALL ENVIRONMENTS
# !!!!!!!!!!!!!!!!!!!!!

# DONOT MAKE ANY CHANGES TO THIS FILE, IT AFFECTS ALL ENVIRONMENTS
locals {
  # Automatically load region-level variables
  region_vars    = read_terragrunt_config("region.hcl")
  env_vars       = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  aws_region     = local.region_vars.locals.aws_region
  aws_account_id = local.env_vars.locals.aws_account_id
  env            = local.env_vars.locals.env
}

# Generate an AWS provider block
# DONOT MAKE ANY CHANGES TO THIS FILE, IT AFFECTS ALL ENVIRONMENTS
generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  allowed_account_ids = ["${local.aws_account_id}"]
}
terraform {
  required_version = ">= 1.1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.46.0"
   }
}
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
# DONOT MAKE ANY CHANGES TO THIS FILE, IT AFFECTS ALL ENVIRONMENTS
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "ipg-acxiom-${local.env}-${local.aws_account_id}-${local.aws_region}-terraform-state-bucket"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "acxiom-${local.env}-terraform-backend"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
#inputs = merge(
#  local.account_vars.locals,
#  local.region_vars.locals,
#  local.environment_vars.locals,
#)
