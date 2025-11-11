variable "name" {
  description = "Secret name"
  type        = string
}

variable "description" {
  description = "Secret description"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "recovery_window_in_days" {
  description = "Recovery window in days"
  type        = number
  default     = 30
}

variable "secret_string" {
  description = "Secret string value"
  type        = string
  default     = null
  sensitive   = true
}

variable "secret_binary" {
  description = "Secret binary value"
  type        = string
  default     = null
  sensitive   = true
}

variable "rotation_enabled" {
  description = "Enable secret rotation"
  type        = bool
  default     = false
}

variable "rotation_lambda_arn" {
  description = "Lambda ARN for rotation"
  type        = string
  default     = null
}

variable "rotation_days" {
  description = "Rotation interval in days"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
