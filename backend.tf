terraform {
  backend "s3" {
    bucket = "my-tfstate-3575857895-lesson-5"
    key = "lesson-7/terraform.tfstate"
    region = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt = true
  }

  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
