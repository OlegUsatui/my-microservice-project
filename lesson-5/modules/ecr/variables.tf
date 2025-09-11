variable "ecr_name" {
  description = "Name for the ECR repository"
  type        = string
}

variable "scan_on_push" {
  description = "Enable image scan on push"
  type        = bool
}
