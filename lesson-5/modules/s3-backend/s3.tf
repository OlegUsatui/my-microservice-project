resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "${var.bucket_name}"
    Environment = "Lesson-5-Terraform-State"
  }
}
