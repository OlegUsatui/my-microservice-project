module "s3_backend" {
  source = "./modules/s3-backend"
  bucket_name = var.tf_state_bucket
  dynamodb_table = var.tf_lock_table
  force_destroy = false
}


module "vpc" {
  source = "./modules/vpc"
  name = var.name
  cidr_block = var.vpc_cidr
  azs = var.azs
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  enable_nat_gw = true
}


module "ecr" {
  source = "./modules/ecr"
  name = var.ecr_name
  scan_on_push = true
}


module "eks" {
  source = "./modules/eks"
  name = var.name
  cluster_version = "1.30"
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids = module.vpc.public_subnet_ids
  node_group_desired = 2
  node_group_max = 4
  node_instance_types = ["t3.large"]
}


module "rds" {
  source = "./modules/rds"
  name = var.name
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  use_aurora = false # set true to create Aurora
  engine = "postgres"
  db_username = var.db_username
  db_password = var.db_password
}


module "jenkins" {
  source = "./modules/jenkins"
  namespace = "jenkins"
  chart_version = "5.3.5" # example for jenkinsci/jenkins
  eks_cluster_name = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
  eks_cluster_ca_data = module.eks.cluster_ca_data
}


module "argo_cd" {
  source = "./modules/argo_cd"
  namespace = "argocd"
  chart_version = "7.6.12" # example for argo/argo-cd
  eks_cluster_name = module.eks.cluster_name
  eks_cluster_endpoint = module.eks.cluster_endpoint
  eks_cluster_ca_data = module.eks.cluster_ca_data
}