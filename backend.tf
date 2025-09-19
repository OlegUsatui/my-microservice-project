terraform {
  backend "s3" {
    bucket = "oleh-usatyi-tfstate-eun1-20250919"
    key = "final-project/terraform.tfstate"
    region = "eu-north-1"
    dynamodb_table = "tf-locks-final-devops"
    encrypt = true
  }
}