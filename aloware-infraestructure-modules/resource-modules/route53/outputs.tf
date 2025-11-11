output "zone_id" {
  description = "Route53 zone ID"
  value       = var.create_zone ? aws_route53_zone.this[0].zone_id : var.zone_id
}

output "zone_name_servers" {
  description = "Route53 zone name servers"
  value       = var.create_zone ? aws_route53_zone.this[0].name_servers : null
}

output "record_names" {
  description = "Route53 record names"
  value       = { for k, v in aws_route53_record.this : k => v.name }
}

output "record_fqdns" {
  description = "Route53 record FQDNs"
  value       = { for k, v in aws_route53_record.this : k => v.fqdn }
}
