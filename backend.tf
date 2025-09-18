terraform {
  backend "s3" {
    bucket = "tfstate-598357935226-lesson-8-9"
    key = "global/terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "tf-locks-lesson-8-9"
    encrypt = true
  }
}
