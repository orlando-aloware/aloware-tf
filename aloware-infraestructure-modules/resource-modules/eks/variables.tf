variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for EKS"
  type        = list(string)
}

variable "enable_irsa" {
  description = "Enable IRSA (IAM Roles for Service Accounts)"
  type        = bool
  default     = true
}

variable "cluster_addons" {
  description = "EKS cluster addons"
  type        = any
  default     = {}
}

variable "eks_managed_node_groups" {
  description = "EKS managed node groups"
  type        = any
  default     = {}
}

variable "cluster_security_group_additional_rules" {
  description = "Additional security group rules for cluster"
  type        = any
  default     = {}
}

variable "node_security_group_additional_rules" {
  description = "Additional security group rules for nodes"
  type        = any
  default     = {}
}

variable "cluster_enabled_log_types" {
  description = "CloudWatch log types to enable"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
