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
  aws_region     = local.env_vars.locals.aws_region
}

# Depend on networking module
dependency "networking" {
  config_path = "../networking"
  
  mock_outputs = {
    vpc_id              = "vpc-mock-id"
    database_subnet_ids = ["subnet-mock-db-1", "subnet-mock-db-2", "subnet-mock-db-3"]
  }
}

inputs = {
  # RDS Aurora Configuration
  cluster_identifier = "aloware-${local.env}-mde-shared-rds-cr"
  engine            = "aurora-mysql"
  engine_version    = "8.0.mysql_aurora.3.04.0"
  engine_mode       = "provisioned"
  
  # Database settings
  database_name   = "aloware"
  master_username = "admin"
  
  # Use AWS Secrets Manager for password
  manage_master_user_password = true
  
  # Networking
  vpc_id             = dependency.networking.outputs.vpc_id
  db_subnet_group_name = dependency.networking.outputs.database_subnet_group_name
  
  # Security
  vpc_security_group_ids = []
  
  # Instance configuration
  instances = {
    one = {
      instance_class      = local.env == "production" ? "db.r6g.large" : "db.t3.medium"
      publicly_accessible = false
    }
  }
  
  # High Availability for production
  availability_zones = local.env == "production" ? [
    "${local.aws_region}a",
    "${local.aws_region}b",
    "${local.aws_region}c"
  ] : ["${local.aws_region}a"]
  
  # Backup and Maintenance
  backup_retention_period      = local.env_vars.locals.backup_retention_days
  preferred_backup_window      = "03:00-04:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"
  
  # Enable backups in staging and production
  skip_final_snapshot       = local.env == "development"
  final_snapshot_identifier = local.env != "development" ? "aloware-${local.env}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null
  
  # Monitoring
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  performance_insights_enabled    = local.env != "development"
  
  # Storage encryption
  storage_encrypted = true
  kms_key_id       = null # Will use default AWS RDS key
  
  # Auto minor version upgrade
  auto_minor_version_upgrade = true
  
  # Deletion protection for production
  deletion_protection = local.env == "production"
  
  # Parameter group
  db_cluster_parameter_group_family = "aurora-mysql8.0"
  
  db_cluster_parameter_group_parameters = [
    {
      name         = "character_set_server"
      value        = "utf8mb4"
      apply_method = "immediate"
    },
    {
      name         = "collation_server"
      value        = "utf8mb4_unicode_ci"
      apply_method = "immediate"
    },
    {
      name         = "max_connections"
      value        = local.env == "production" ? "1000" : "500"
      apply_method = "immediate"
    }
  ]
  
  # Tags
  tags = {
    Module = "database"
    Tier   = "data"
  }
}
