terraform {
  source = "${get_repo_root()}/../../aloware-infraestructure-modules//composite-modules/application"
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

# Dependencies
dependency "eks_cluster" {
  config_path = "../eks-cluster"
  
  mock_outputs = {
    cluster_name                   = "mock-cluster"
    cluster_endpoint              = "https://mock-endpoint"
    cluster_certificate_authority = "mock-ca"
    oidc_provider_arn            = "arn:aws:iam::123456789012:oidc-provider/mock"
  }
}

dependency "database" {
  config_path = "../database"
  
  mock_outputs = {
    cluster_endpoint = "mock-db-endpoint"
    cluster_reader_endpoint = "mock-db-reader-endpoint"
    master_username = "admin"
    database_name   = "aloware"
  }
}

dependency "storage" {
  config_path = "../storage"
  
  mock_outputs = {
    ecr_repository_urls = {
      "api-core/api"   = "123456789012.dkr.ecr.us-west-2.amazonaws.com/api-core/api"
      "api-core/queue" = "123456789012.dkr.ecr.us-west-2.amazonaws.com/api-core/queue"
    }
  }
}

inputs = {
  # Application Configuration
  app_name     = "api-core"
  app_version  = "latest"
  
  # EKS Configuration
  cluster_name  = dependency.eks_cluster.outputs.cluster_name
  namespace     = "app"
  
  # Container Images
  api_image   = "${dependency.storage.outputs.ecr_repository_urls["api-core/api"]}:app"
  queue_image = "${dependency.storage.outputs.ecr_repository_urls["api-core/queue"]}:app"
  
  # Database Configuration
  db_host     = dependency.database.outputs.cluster_endpoint
  db_name     = dependency.database.outputs.database_name
  db_username = dependency.database.outputs.master_username
  
  # AWS SSM Parameter Store paths for application config
  ssm_parameter_paths = {
    shared = "/shared/api-core/app/"
    env    = "/${local.env}/api-core/app/"
  }
  
  # Helm Chart Configuration
  helm_chart_version = "1.0.0"
  
  # Application Scaling
  api_replicas = {
    min     = local.env == "production" ? 3 : 1
    max     = local.env == "production" ? 20 : 5
    desired = local.env == "production" ? 5 : 2
  }
  
  queue_replicas = {
    min     = local.env == "production" ? 2 : 1
    max     = local.env == "production" ? 10 : 3
    desired = local.env == "production" ? 3 : 1
  }
  
  # Resource Requests and Limits
  api_resources = {
    requests = {
      cpu    = local.env == "production" ? "500m" : "250m"
      memory = local.env == "production" ? "1Gi" : "512Mi"
    }
    limits = {
      cpu    = local.env == "production" ? "2000m" : "1000m"
      memory = local.env == "production" ? "2Gi" : "1Gi"
    }
  }
  
  queue_resources = {
    requests = {
      cpu    = local.env == "production" ? "500m" : "250m"
      memory = local.env == "production" ? "1Gi" : "512Mi"
    }
    limits = {
      cpu    = local.env == "production" ? "2000m" : "1000m"
      memory = local.env == "production" ? "2Gi" : "1Gi"
    }
  }
  
  # Health Checks
  liveness_probe = {
    path                = "/health"
    port                = 80
    initial_delay_seconds = 30
    period_seconds       = 10
    timeout_seconds      = 5
    success_threshold    = 1
    failure_threshold    = 3
  }
  
  readiness_probe = {
    path                = "/ready"
    port                = 80
    initial_delay_seconds = 15
    period_seconds       = 10
    timeout_seconds      = 5
    success_threshold    = 1
    failure_threshold    = 3
  }
  
  # Ingress Configuration
  ingress = {
    enabled = true
    domain  = local.env == "production" ? "api.aloware.com" : (local.env == "staging" ? "api.alostaging.com" : "api.alodev.org")
    tls_enabled = true
    annotations = {
      "kubernetes.io/ingress.class"                = "alb"
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/certificate-arn"  = local.env == "production" ? "PRODUCTION_CERT_ARN" : (local.env == "staging" ? "STAGING_CERT_ARN" : "DEV_CERT_ARN")
    }
  }
  
  # Service Account (IRSA)
  service_account = {
    create = true
    name   = "api-core-sa"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${local.aws_account_id}:role/aloware-${local.env}-api-core-role"
    }
  }
  
  # Enable MDE for development
  enable_mde = local.env_vars.locals.enable_mde
  
  # Tags
  tags = {
    Module      = "application"
    Application = "api-core"
    Tier        = "application"
  }
}
