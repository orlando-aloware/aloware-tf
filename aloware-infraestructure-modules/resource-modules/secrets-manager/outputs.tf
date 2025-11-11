output "secret_id" {
  description = "Secret ID"
  value       = aws_secretsmanager_secret.this.id
}

output "secret_arn" {
  description = "Secret ARN"
  value       = aws_secretsmanager_secret.this.arn
}

output "secret_version_id" {
  description = "Secret version ID"
  value       = length(aws_secretsmanager_secret_version.this) > 0 ? aws_secretsmanager_secret_version.this[0].version_id : null
}
