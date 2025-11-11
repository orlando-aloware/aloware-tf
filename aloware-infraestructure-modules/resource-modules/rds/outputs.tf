output "cluster_arn" {
  description = "Cluster ARN"
  value       = module.rds_aurora.cluster_arn
}

output "cluster_id" {
  description = "Cluster ID"
  value       = module.rds_aurora.cluster_id
}

output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = module.rds_aurora.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "Cluster reader endpoint"
  value       = module.rds_aurora.cluster_reader_endpoint
}

output "cluster_master_username" {
  description = "Master username"
  value       = module.rds_aurora.cluster_master_username
  sensitive   = true
}

output "database_name" {
  description = "Database name"
  value       = module.rds_aurora.cluster_database_name
}
