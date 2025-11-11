output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate.this.arn
}

output "certificate_domain_name" {
  description = "ACM certificate domain name"
  value       = aws_acm_certificate.this.domain_name
}

output "certificate_status" {
  description = "ACM certificate status"
  value       = aws_acm_certificate.this.status
}

output "validation_record_fqdns" {
  description = "Validation record FQDNs"
  value       = [for record in aws_route53_record.validation : record.fqdn]
}
