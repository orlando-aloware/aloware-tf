variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  description = "Read capacity units (PROVISIONED mode only)"
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "Write capacity units (PROVISIONED mode only)"
  type        = number
  default     = null
}

variable "hash_key" {
  description = "Partition key attribute name"
  type        = string
}

variable "range_key" {
  description = "Sort key attribute name"
  type        = string
  default     = null
}

variable "attributes" {
  description = "List of attribute definitions"
  type = list(object({
    name = string
    type = string
  }))
}

variable "global_secondary_indexes" {
  description = "List of global secondary indexes"
  type        = list(any)
  default     = []
}

variable "local_secondary_indexes" {
  description = "List of local secondary indexes"
  type        = list(any)
  default     = []
}

variable "ttl_enabled" {
  description = "Enable TTL"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "TTL attribute name"
  type        = string
  default     = ""
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "server_side_encryption_enabled" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "server_side_encryption_kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
  default     = null
}

variable "stream_enabled" {
  description = "Enable DynamoDB streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
