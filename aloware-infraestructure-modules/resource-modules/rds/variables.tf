variable "cluster_identifier" {
  description = "Cluster identifier"
  type        = string
}

variable "engine" {
  description = "Database engine"
  type        = string
}

variable "engine_version" {
  description = "Engine version"
  type        = string
}

variable "engine_mode" {
  description = "Engine mode"
  type        = string
  default     = "provisioned"
}

variable "database_name" {
  description = "Name of database"
  type        = string
}

variable "master_username" {
  description = "Master username"
  type        = string
}

variable "manage_master_user_password" {
  description = "Manage password via Secrets Manager"
  type        = bool
  default     = true
}

variable "master_password" {
  description = "Master password (if not using Secrets Manager)"
  type        = string
  default     = null
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "db_subnet_group_name" {
  description = "DB subnet group name"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "VPC security group IDs"
  type        = list(string)
  default     = []
}

variable "instances" {
  description = "Instance configuration"
  type        = any
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "Preferred maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on delete"
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Final snapshot identifier"
  type        = string
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "CloudWatch log exports"
  type        = list(string)
  default     = []
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "db_cluster_parameter_group_name" {
  description = "DB cluster parameter group name"
  type        = string
  default     = null
}

variable "db_cluster_parameter_group_family" {
  description = "DB cluster parameter group family"
  type        = string
}

variable "db_cluster_parameter_group_parameters" {
  description = "DB cluster parameter group parameters"
  type        = list(map(string))
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
