locals {
  name_prefix = "${var.project_name}"
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

data "aws_availability_zones" "available" {}

module "s3_backend_bootstrap" {
  source = "./modules/s3-backend"
  bucket_name = "${var.project_name}-tfstate"
  dynamodb_table_name = "${var.project_name}-tflock"
}

module "vpc" {
  source = "./modules/vpc"
  name = local.name_prefix
  cidr_block = "10.0.0.0/16"
  azs = local.azs
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
}

# === RDS Module usage examples ===
# Aurora PostgreSQL
module "rds_aurora" {
  source = "./modules/rds"
  name = "${local.name_prefix}-aurora"
  use_aurora = true
  engine = "aurora-postgresql"
  engine_version = "15.4"
  instance_class = "db.r6g.large"
  db_name = "appdb"
  master_username = "dbadmin"
  master_password = var.db_master_password
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  allowed_cidr_blocks = [module.vpc.vpc_cidr]
  port = 5432
  multi_az = false
  parameter_overrides = {
    log_statement = "none"
    work_mem = "65536"
    max_connections = "200"
  }
}

# Single-instance PostgreSQL
module "rds_instance" {
  source = "./modules/rds"
  name = "${local.name_prefix}-pg"
  use_aurora = false
  engine = "postgres"
  engine_version = "15.6"
  instance_class = "db.t4g.medium"
  db_name = "appdb"
  master_username = "dbadmin"
  master_password = var.db_master_password
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  allowed_cidr_blocks = [module.vpc.vpc_cidr]
  port = 5432
  multi_az = false
  storage_gb = 20
  storage_type = "gp3"
  deletion_protection = false
  backup_retention_days = 1
  parameter_overrides = {
    log_statement = "none"
    work_mem = "65536"
    max_connections = "200"
  }
}

output "aurora_endpoint" {
  value = module.rds_aurora.writer_endpoint
}

output "rds_instance_endpoint" {
  value = module.rds_instance.instance_endpoint
}
