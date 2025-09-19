resource "aws_ecr_repository" "this" {
  name = var.name
  image_scanning_configuration { scan_on_push = var.scan_on_push }
  encryption_configuration { encryption_type = "AES256" }
}