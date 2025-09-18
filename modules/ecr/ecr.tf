resource "aws_ecr_repository" "this" {
  name = var.repo_name
  image_tag_mutability = var.image_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  force_delete = var.force_delete
}
