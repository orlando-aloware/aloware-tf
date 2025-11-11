output "parameter_arns" {
  description = "SSM parameter ARNs"
  value       = { for k, v in aws_ssm_parameter.this : k => v.arn }
}

output "parameter_names" {
  description = "SSM parameter names"
  value       = { for k, v in aws_ssm_parameter.this : k => v.name }
}

output "parameter_versions" {
  description = "SSM parameter versions"
  value       = { for k, v in aws_ssm_parameter.this : k => v.version }
}
