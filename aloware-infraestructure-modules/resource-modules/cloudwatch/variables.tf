variable "create_log_group" {
  description = "Create CloudWatch log group"
  type        = bool
  default     = false
}

variable "log_group_name" {
  description = "CloudWatch log group name"
  type        = string
  default     = null
}

variable "retention_in_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}

variable "kms_key_id" {
  description = "KMS key ID for log encryption"
  type        = string
  default     = null
}

variable "metric_alarms" {
  description = "Map of CloudWatch metric alarms"
  type        = map(any)
  default     = {}
}

variable "create_dashboard" {
  description = "Create CloudWatch dashboard"
  type        = bool
  default     = false
}

variable "dashboard_name" {
  description = "CloudWatch dashboard name"
  type        = string
  default     = null
}

variable "dashboard_body" {
  description = "CloudWatch dashboard body (JSON)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
