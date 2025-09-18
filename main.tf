module "s3_backend" {
  source = "./modules/s3-backend"
  bucket_name = var.backend_bucket_name
  dynamodb_table = var.backend_lock_table
  project_name = var.project_name
}

module "vpc" {
  source              = "./modules/vpc"
  name                = "${var.project_name}-vpc"
  cidr_block          = "10.0.0.0/16"
  azs                 = ["eu-central-1a", "eu-central-1b"]
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
}

module "ecr" {
  source     = "./modules/ecr"
  repo_name  = var.ecr_repo_name
}

module "eks" {
  source                = "./modules/eks"
  cluster_name          = var.cluster_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  node_group_min_size   = 1
  node_group_max_size   = 3
  node_instance_types   = ["t3.medium"]
}

module "jenkins" {
  source         = "./modules/jenkins"
  namespace      = "jenkins"
  admin_user     = "admin"
  admin_password = "CHANGEME"
}