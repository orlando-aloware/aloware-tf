terraform {
  source = "${get_repo_root()}/../../aloware-infraestructure-modules//composite-modules/database"
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
    vpc_id           = "vpc-mock"
    database_subnets = ["subnet-mock1", "subnet-mock2", "subnet-mock3"]
  }
}

dependency "shared_resources" {
  config_path = "../shared-resources"
  mock_outputs = {
    kms_key_id = "mock-kms-key"
  }
}

inputs = {
  # RDS Aurora MySQL cluster configuration
  cluster_identifier = "aloware-prod-aurora-mysql"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.05.2" # Update based on AWS RDS available versions
  
  # Instance configuration - Production sizing
  instance_class = "db.r6g.2xlarge" # 8 vCPU, 64 GB RAM
  instances = {
    1 = {
      identifier     = "aloware-prod-aurora-mysql-1"
      instance_class = "db.r6g.2xlarge"
    }
    2 = {
      identifier     = "aloware-prod-aurora-mysql-2"
      instance_class = "db.r6g.2xlarge"
    }
    3 = {
      identifier     = "aloware-prod-aurora-mysql-3"
      instance_class = "db.r6g.2xlarge"
    }
  }
  
  # Network configuration
  vpc_id     = dependency.networking.outputs.vpc_id
  subnet_ids = dependency.networking.outputs.database_subnets
  
  # Database configuration
  database_name   = "aloware_production"
  master_username = "aloware_admin"
  port            = 3306
  
  # High availability and backup
  backup_retention_period      = 30 # 30 days for production
  preferred_backup_window      = "03:00-04:00" # 3 AM - 4 AM UTC
  preferred_maintenance_window = "sun:04:00-sun:05:00"
  
  # Point-in-time recovery
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  
  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  
  # Encryption
  storage_encrypted = true
  kms_key_id        = dependency.shared_resources.outputs.kms_key_id
  
  # Deletion protection
  deletion_protection = true
  skip_final_snapshot = false
  final_snapshot_identifier = "aloware-prod-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  # Auto minor version upgrade
  auto_minor_version_upgrade = false # Manual control in production
  
  # Monitoring
  monitoring_interval = 60 # Enhanced monitoring every 60 seconds
  
  # Parameter group settings for production optimization
  db_parameter_group_name         = "aloware-prod-mysql8-0"
  db_cluster_parameter_group_name = "aloware-prod-aurora-mysql8-0"
  
  db_cluster_parameter_group_parameters = [
    {
      name  = "character_set_server"
      value = "utf8mb4"
    },
    {
      name  = "collation_server"
      value = "utf8mb4_unicode_ci"
    },
    {
      name  = "max_connections"
      value = "1000"
    },
    {
      name  = "innodb_buffer_pool_size"
      value = "{DBInstanceClassMemory*3/4}" # 75% of instance memory
    },
  ]
  
  # Security group configuration
  allowed_cidr_blocks = []
  allowed_security_groups = [] # Will be set to allow EKS nodes
  
  # Production tags
  tags = {
    Module           = "database"
    Tier             = "data"
    Criticality      = "critical"
    DisasterRecovery = "required"
    BackupPolicy     = "required"
    MonitoringLevel  = "enhanced"
    DataRetention    = "30-days"
    Compliance       = "PCI-DSS"
  }
}
