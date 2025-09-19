module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "20.24.0"
  cluster_name = var.name
  cluster_version = var.cluster_version
  vpc_id = var.vpc_id
  subnet_ids = var.private_subnet_ids


  eks_managed_node_groups = {
    default = {
      desired_size = var.node_group_desired
      max_size = var.node_group_max
      min_size = 1
      instance_types = var.node_instance_types
    }
  }
}