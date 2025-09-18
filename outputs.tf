output "ecr_repository_url" {
  description = "URL ECR репозиторію"
  value = module.ecr.repository_url
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "update_kubeconfig_cmd" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
