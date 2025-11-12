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
  aws_region     = local.env_vars.locals.aws_region
}

inputs = {
  # VPC Configuration
  vpc_name = "aloware-${local.env}-vpc"
  vpc_cidr = "10.0.0.0/16"
  
  # Subnets
  availability_zones = ["${local.aws_region}a", "${local.aws_region}b", "${local.aws_region}c"]
  
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
  
  # NAT Gateway
  enable_nat_gateway   = local.env_vars.locals.enable_nat_gateway
  single_nat_gateway   = local.env_vars.locals.single_nat_gateway
  enable_vpn_gateway   = local.env_vars.locals.enable_vpn_gateway
  
  # DNS
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  # VPC Flow Logs
  enable_flow_log                      = true
  flow_log_destination_type            = "cloud-watch-logs"
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_retention_in_days           = local.env_vars.locals.log_retention_days
  
  # Tags
  tags = {
    Module = "networking"
    Tier   = "infrastructure"
  }
}
