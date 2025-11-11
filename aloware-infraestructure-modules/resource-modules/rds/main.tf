module "rds_aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 8.0"

  name           = var.cluster_identifier
  engine         = var.engine
  engine_version = var.engine_version
  engine_mode    = var.engine_mode

  database_name   = var.database_name
  master_username = var.master_username

  manage_master_user_password = var.manage_master_user_password
  master_password             = var.manage_master_user_password ? null : var.master_password

  vpc_id                 = var.vpc_id
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  instances = var.instances

  availability_zones = var.availability_zones

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  performance_insights_enabled    = var.performance_insights_enabled

  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  deletion_protection        = var.deletion_protection

  db_cluster_parameter_group_name        = var.db_cluster_parameter_group_name
  db_cluster_parameter_group_family      = var.db_cluster_parameter_group_family
  db_cluster_parameter_group_parameters  = var.db_cluster_parameter_group_parameters

  tags = var.tags
}
