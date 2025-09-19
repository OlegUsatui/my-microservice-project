output "vpc_id" { value = module.vpc.vpc_id }
output "cluster_name" { value = module.eks.cluster_name }
output "ecr_url" { value = module.ecr.repository_url }
output "rds_endpoint" { value = module.rds.endpoint }
output "jenkins_namespace" { value = module.jenkins.namespace }
output "argocd_namespace" { value = module.argo_cd.namespace }