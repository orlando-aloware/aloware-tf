terraform {
  source = "${get_repo_root()}/../../aloware-infraestructure-modules//composite-modules/networking"
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
  # VPC Configuration
  vpc_name = "aloware-${local.env}-vpc"
  vpc_cidr = "10.2.0.0/16" # Production uses 10.2.x.x (dev: 10.0.x.x, staging: 10.1.x.x)
  
  # Multi-AZ configuration for high availability
  availability_zones = ["${local.aws_region}a", "${local.aws_region}b", "${local.aws_region}c"]
  
  # Private subnets for application workloads (EKS nodes, app servers)
  private_subnets = [
    "10.2.1.0/24",   # us-west-2a
    "10.2.2.0/24",   # us-west-2b
    "10.2.3.0/24"    # us-west-2c
  ]
  
  # Public subnets for load balancers and NAT gateways
  public_subnets = [
    "10.2.101.0/24", # us-west-2a
    "10.2.102.0/24", # us-west-2b
    "10.2.103.0/24"  # us-west-2c
  ]
  
  # Database subnets (isolated for security)
  database_subnets = [
    "10.2.201.0/24", # us-west-2a
    "10.2.202.0/24", # us-west-2b
    "10.2.203.0/24"  # us-west-2c
  ]
  
  # NAT Gateway configuration - Multiple for HA in production
  enable_nat_gateway = true
  single_nat_gateway = false # One NAT gateway per AZ for high availability
  enable_vpn_gateway = false
  
  # DNS configuration
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  # VPC Flow Logs for security and compliance
  enable_flow_log                      = true
  flow_log_destination_type            = "cloud-watch-logs"
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_retention_in_days           = 90 # Compliance requirement
  
  # VPC Endpoints for cost optimization and security
  enable_s3_endpoint       = true
  enable_ecr_endpoint      = true
  enable_secrets_endpoint  = true
  enable_ssm_endpoint      = true
  
  # Production tags
  tags = {
    Module              = "networking"
    Tier                = "infrastructure"
    Criticality         = "high"
    DisasterRecovery    = "required"
    BackupPolicy        = "required"
    MonitoringLevel     = "enhanced"
  }
}
