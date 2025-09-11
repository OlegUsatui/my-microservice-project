# ECR Repository
resource "aws_ecr_repository" "main" {
  name                 = var.ecr_name
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name = var.ecr_name
  }
}

# Repository policy to allow public read (pull) access to images
resource "aws_ecr_repository_policy" "public_read" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPull"
        Effect    = "Allow"
        Principal = {"AWS": "*"}
        Action    = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}
