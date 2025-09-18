resource "aws_dynamodb_table" "locks" {
  name = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = { Project = var.project_name, Role = "tflock" }
}
