output "s3_bucket_url" {
  description = "Regional S3 bucket URL for state storage"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "dynamodb_table_name" {
  description = "Name of DynamoDB lock table"
  value       = aws_dynamodb_table.lock.name
}
