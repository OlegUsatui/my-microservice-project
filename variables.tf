variable "aws_region" { type = string  default = "eu-central-1" }
variable "project_name" { type = string  default = "lesson-8-9" }
variable "backend_bucket_name" { type = string }
variable "backend_lock_table" { type = string  default = "tf-locks-lesson-8-9" }
