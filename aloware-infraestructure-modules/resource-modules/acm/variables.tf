variable "domain_name" {
  description = "Domain name for certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "Subject alternative names"
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "Validation method (DNS or EMAIL)"
  type        = string
  default     = "DNS"
}

variable "certificate_transparency_logging_preference" {
  description = "Certificate transparency logging preference"
  type        = string
  default     = "ENABLED"
}

variable "create_route53_records" {
  description = "Create Route53 validation records"
  type        = bool
  default     = false
}

variable "route53_zone_id" {
  description = "Route53 zone ID for validation records"
  type        = string
  default     = null
}

variable "wait_for_validation" {
  description = "Wait for certificate validation"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
