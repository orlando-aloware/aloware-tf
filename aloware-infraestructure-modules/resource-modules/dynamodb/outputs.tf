output "table_id" {
  description = "DynamoDB table ID"
  value       = aws_dynamodb_table.this.id
}

output "table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.this.arn
}

output "table_stream_arn" {
  description = "DynamoDB stream ARN"
  value       = aws_dynamodb_table.this.stream_arn
}

output "table_stream_label" {
  description = "DynamoDB stream label"
  value       = aws_dynamodb_table.this.stream_label
}
