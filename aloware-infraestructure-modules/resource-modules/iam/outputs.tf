output "role_arn" {
  description = "IAM role ARN"
  value       = var.create_role ? aws_iam_role.this[0].arn : null
}

output "role_name" {
  description = "IAM role name"
  value       = var.create_role ? aws_iam_role.this[0].name : null
}

output "policy_arn" {
  description = "IAM policy ARN"
  value       = var.create_policy ? aws_iam_policy.this[0].arn : null
}

output "instance_profile_arn" {
  description = "Instance profile ARN"
  value       = var.create_instance_profile ? aws_iam_instance_profile.this[0].arn : null
}
