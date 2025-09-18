
variable "aws_region" { type = string }
variable "vpc_name" { type = string }
variable "vpc_cidr_block" { type = string }
variable "availability_zones" { type = list(string) }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "ecr_name" { type = string }
variable "scan_on_push" { type = bool }
variable "cluster_name" { type = string   default = "goit-lesson7" }
variable "cluster_version" { type = string   default = "1.29" }
variable "instance_types" { type = list(string) default = ["t3.medium"] }
variable "min_size" { type = number  default = 2 }
variable "desired_size" { type = number  default = 2 }
variable "max_size" { type = number  default = 6 }


module "vpc" {
  source = "./modules/vpc"
  vpc_name = var.vpc_name
  vpc_cidr_block = var.vpc_cidr_block
  availability_zones = var.availability_zones
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
}


module "ecr" {
  source = "./modules/ecr"
  repo_name = var.ecr_name
  scan_on_push = var.scan_on_push
  force_delete = true
  image_mutability = "MUTABLE"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id = module.vpc.vpc_id
  subnet_ids = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  enable_irsa = true

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      desired_size = var.desired_size
      min_size = var.min_size
      max_size = var.max_size
      instance_types = var.instance_types
      subnet_ids = module.vpc.private_subnet_ids
    }
  }

  cluster_addons = {
    coredns = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni = { most_recent = true }
  }

  tags = {
    Project = "lesson-7"
  }
}
