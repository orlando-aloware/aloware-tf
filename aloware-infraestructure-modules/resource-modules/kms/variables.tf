variable "name" {
  description = "KMS key name"
  type        = string
}

variable "description" {
  description = "KMS key description"
  type        = string
}

variable "alias" {
  description = "KMS key alias"
  type        = string
  default     = null
}

variable "deletion_window_in_days" {
  description = "Deletion window in days"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Enable automatic key rotation"
  type        = bool
  default     = true
}

variable "multi_region" {
  description = "Create multi-region key"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
