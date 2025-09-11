output "state_backend_bucket_url" {
  description = "S3 bucket URL for Terraform state"
  value       = module.s3_backend.s3_bucket_url
}

output "state_lock_table" {
  description = "DynamoDB table name for state locking"
  value       = module.s3_backend.dynamodb_table_name
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets in the VPC"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets in the VPC"
  value       = module.vpc.private_subnet_ids
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}
