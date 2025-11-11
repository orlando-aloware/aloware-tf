output "log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = var.create_log_group ? aws_cloudwatch_log_group.this[0].arn : null
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = var.create_log_group ? aws_cloudwatch_log_group.this[0].name : null
}

output "metric_alarm_arns" {
  description = "CloudWatch metric alarm ARNs"
  value       = { for k, v in aws_cloudwatch_metric_alarm.this : k => v.arn }
}

output "dashboard_arn" {
  description = "CloudWatch dashboard ARN"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.this[0].dashboard_arn : null
}
