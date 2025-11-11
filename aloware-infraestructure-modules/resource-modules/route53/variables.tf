variable "create_zone" {
  description = "Create Route53 hosted zone"
  type        = bool
  default     = false
}

variable "zone_name" {
  description = "Route53 zone name"
  type        = string
  default     = null
}

variable "zone_id" {
  description = "Existing Route53 zone ID"
  type        = string
  default     = null
}

variable "private_zone" {
  description = "Is private hosted zone"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID for private zone"
  type        = string
  default     = null
}

variable "records" {
  description = "Map of Route53 records"
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
