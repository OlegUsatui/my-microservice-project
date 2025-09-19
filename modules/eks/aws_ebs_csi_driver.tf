resource "aws_eks_addon" "ebs_csi" {
  cluster_name = module.eks.cluster_name
  addon_name = "aws-ebs-csi-driver"
  resolve_conflicts_on_create = "OVERWRITE"
}