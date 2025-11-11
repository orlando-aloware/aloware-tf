output "lb_id" {
  description = "ALB ID"
  value       = module.alb.lb_id
}

output "lb_arn" {
  description = "ALB ARN"
  value       = module.alb.lb_arn
}

output "lb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.lb_dns_name
}

output "lb_zone_id" {
  description = "ALB zone ID"
  value       = module.alb.lb_zone_id
}

output "target_group_arns" {
  description = "Target group ARNs"
  value       = module.alb.target_group_arns
}

output "http_tcp_listener_arns" {
  description = "HTTP listener ARNs"
  value       = module.alb.http_tcp_listener_arns
}

output "https_listener_arns" {
  description = "HTTPS listener ARNs"
  value       = module.alb.https_listener_arns
}
