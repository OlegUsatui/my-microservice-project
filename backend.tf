terraform {
  backend "s3" {
    bucket = "tfstate-598357935226-lesson-8-9"
    key = "lesson-db-module/terraform.tfstate"
    region = "eu-north-1"
    dynamodb_table = "tf-locks-lesson-8-9"
    encrypt        = true
  }
}
