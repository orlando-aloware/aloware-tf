output "repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.this.arn
}

output "repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.this.repository_url
}

output "registry_id" {
  description = "ECR registry ID"
  value       = aws_ecr_repository.this.registry_id
}
