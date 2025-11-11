variable "parameters" {
  description = "Map of SSM parameters to create"
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to all parameters"
  type        = map(string)
  default     = {}
}
