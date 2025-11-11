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
  region_vars    = read_terragrunt_config("region.hcl")
  aws_region     = local.region_vars.locals.aws_region
  config         = yamldecode(file("${get_repo_root()}/aloware-iac/config/production.yaml"))
}

dependency "networking" {
  config_path = "../networking"
  mock_outputs = {
    vpc_id         = "vpc-mock"
    public_subnets = ["subnet-mock1", "subnet-mock2", "subnet-mock3"]
  }
}

dependency "eks_cluster" {
  config_path = "../eks-cluster"
  mock_outputs = {
    cluster_name     = "mock-cluster"
    cluster_endpoint = "https://mock-endpoint"
  }
}

dependency "database" {
  config_path = "../database"
  mock_outputs = {
    cluster_endpoint = "mock-db-endpoint"
    cluster_name     = "mock-db-cluster"
  }
}

dependency "storage" {
  config_path = "../storage"
  mock_outputs = {
    ecr_repository_urls = {
      api-core = "mock-ecr-url"
      talk2    = "mock-ecr-url"
    }
  }
}

inputs = {
  # Application Load Balancer configuration
  alb_name = "aloware-prod-alb"
  
  # Network configuration
  vpc_id  = dependency.networking.outputs.vpc_id
  subnets = dependency.networking.outputs.public_subnets
  
  # SSL/TLS Certificate
  # Domain: app.aloware.com, *.aloware.com
  certificate_domain_name = "aloware.com"
  certificate_subject_alternative_names = [
    "*.aloware.com",
    "app.aloware.com",
    "api.aloware.com"
  ]
  
  # Route53 configuration
  route53_zone_name = "aloware.com"
  create_route53_zone = false # Zone should already exist
  
  dns_records = {
    app = {
      name = "app"
      type = "A"
      alias = {
        evaluate_target_health = true
      }
    }
    api = {
      name = "api"
      type = "A"
      alias = {
        evaluate_target_health = true
      }
    }
  }
  
  # ALB Listeners
  http_tcp_listeners = [
    {
      port     = 80
      protocol = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
  
  https_listeners = [
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "" # Will be populated from ACM
      action_type     = "forward"
    }
  ]
  
  # Target Groups
  target_groups = [
    {
      name             = "aloware-prod-api"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/health"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-299"
      }
    }
  ]
  
  # WAF configuration for production security
  enable_waf = true
  waf_rules = [
    "AWSManagedRulesCommonRuleSet",
    "AWSManagedRulesKnownBadInputsRuleSet",
    "AWSManagedRulesSQLiRuleSet"
  ]
  
  # Access logs
  enable_access_logs = true
  access_logs_bucket = "" # Will be set to logs bucket from storage
  
  # Deletion protection
  enable_deletion_protection = true
  
  # EKS integration
  eks_cluster_name = dependency.eks_cluster.outputs.cluster_name
  
  # SSM Parameters for application configuration
  ssm_parameters = {
    eks_cluster_endpoint = {
      name  = "/aloware/production/eks/cluster-endpoint"
      value = dependency.eks_cluster.outputs.cluster_endpoint
      type  = "String"
    }
    db_endpoint = {
      name  = "/aloware/production/database/endpoint"
      value = dependency.database.outputs.cluster_endpoint
      type  = "String"
    }
    ecr_api_core = {
      name  = "/aloware/production/ecr/api-core"
      value = dependency.storage.outputs.ecr_repository_urls["api-core"]
      type  = "String"
    }
    alb_dns_name = {
      name  = "/aloware/production/alb/dns-name"
      value = "" # Will be set after ALB creation
      type  = "String"
    }
  }
  
  # Production tags
  tags = {
    Module           = "application"
    Tier             = "application"
    Criticality      = "critical"
    DisasterRecovery = "required"
    BackupPolicy     = "not-applicable"
    MonitoringLevel  = "enhanced"
    WAF              = "enabled"
  }
}
