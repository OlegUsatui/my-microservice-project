output "cluster_name" { value = aws_eks_cluster.this.name }
output "oidc_issuer"  { value = aws_eks_cluster.this.identity[0].oidc[0].issuer }
