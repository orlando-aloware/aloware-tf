variable "name" {
  description = "ALB name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "Subnet IDs for ALB"
  type        = list(string)
}

variable "security_groups" {
  description = "Security group IDs"
  type        = list(string)
  default     = []
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Enable HTTP/2"
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

variable "access_logs" {
  description = "Access logs configuration"
  type        = any
  default     = {}
}

variable "target_groups" {
  description = "Target groups configuration"
  type        = any
  default     = []
}

variable "http_tcp_listeners" {
  description = "HTTP listeners configuration"
  type        = any
  default     = []
}

variable "https_listeners" {
  description = "HTTPS listeners configuration"
  type        = any
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
