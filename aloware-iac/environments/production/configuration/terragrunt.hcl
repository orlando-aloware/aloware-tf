terraform {
  source = "${get_repo_root()}/../../aloware-infraestructure-modules//composite-modules/configuration"
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
    artifacts_bucket_name = "mock-artifacts-bucket"
    kms_key_id           = "mock-kms-key"
  }
}

inputs = {
  env            = local.env
  aws_account_id = local.aws_account_id
  aws_region     = local.aws_region
  
  # SSM Parameters for production configuration
  # These will be used by Jenkins pipelines and applications
  ssm_parameters = {
    # Database parameters
    db_host = {
      name        = "/aloware/production/database/host"
      type        = "String"
      description = "Production RDS cluster endpoint"
    }
    db_name = {
      name        = "/aloware/production/database/name"
      type        = "String"
      description = "Production database name"
    }
    db_port = {
      name        = "/aloware/production/database/port"
      type        = "String"
      value       = "3306"
      description = "Production database port"
    }
    
    # EKS configuration
    eks_cluster_name = {
      name        = "/aloware/production/eks/cluster-name"
      type        = "String"
      description = "Production EKS cluster name"
    }
    eks_region = {
      name        = "/aloware/production/eks/region"
      type        = "String"
      value       = local.aws_region
      description = "Production EKS cluster region"
    }
    
    # ECR configuration
    ecr_registry = {
      name        = "/aloware/production/ecr/registry"
      type        = "String"
      description = "Production ECR registry URL"
    }
    
    # Application configuration
    app_env = {
      name        = "/aloware/production/app/environment"
      type        = "String"
      value       = "production"
      description = "Application environment"
    }
  }
  
  # Secrets that should be in Secrets Manager (not SSM)
  secrets = {
    db_password = {
      name        = "aloware/production/database/password"
      description = "Production database master password"
    }
    app_secret_key = {
      name        = "aloware/production/app/secret-key"
      description = "Production application secret key"
    }
  }
  
  # Lambda artifacts bucket from shared resources
  lambda_s3_bucket = dependency.shared_resources.outputs.artifacts_bucket_name
  
  # KMS key for encryption
  kms_key_id = dependency.shared_resources.outputs.kms_key_id
  
  # Production tags
  tags = {
    Project             = "Aloware"
    Environment         = "production"
    ManagedBy           = "Terraform"
    CostCenter          = "Engineering"
    Compliance          = "Required"
    DataClassification  = "Confidential"
  }
}
