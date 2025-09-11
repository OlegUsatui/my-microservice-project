variable "bucket_name" {
  description = "Name of the S3 bucket to store Terraform state"
  type        = string
}

variable "table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
}
