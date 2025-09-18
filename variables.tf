variable "aws_region" { type = string  default = "eu-central-1" }
variable "project_name" { type = string  default = "lesson-8-9" }
variable "backend_bucket_name" { type = string }
variable "backend_lock_table" { type = string  default = "tf-locks-lesson-8-9" }
variable "cluster_name"  { type = string  default = "lesson-8-9-eks" }
variable "ecr_repo_name" { type = string  default = "django-app" }