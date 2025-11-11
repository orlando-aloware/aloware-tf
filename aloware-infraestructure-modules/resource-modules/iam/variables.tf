variable "create_role" {
  description = "Create IAM role"
  type        = bool
  default     = true
}

variable "role_name" {
  description = "IAM role name"
  type        = string
  default     = null
}

variable "role_description" {
  description = "IAM role description"
  type        = string
  default     = null
}

variable "assume_role_policy" {
  description = "Assume role policy JSON"
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds"
  type        = number
  default     = 3600
}

variable "role_policy_arns" {
  description = "Map of policy ARNs to attach to role"
  type        = map(string)
  default     = {}
}

variable "create_policy" {
  description = "Create IAM policy"
  type        = bool
  default     = false
}

variable "policy_name" {
  description = "IAM policy name"
  type        = string
  default     = null
}

variable "policy_description" {
  description = "IAM policy description"
  type        = string
  default     = null
}

variable "policy_document" {
  description = "IAM policy document JSON"
  type        = string
  default     = null
}

variable "create_instance_profile" {
  description = "Create instance profile"
  type        = bool
  default     = false
}

variable "instance_profile_name" {
  description = "Instance profile name"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
