locals {
  is_pg      = contains(["postgres", "aurora-postgresql"], var.engine)
  family     = var.engine == "postgres"           ? "postgres15" :
               var.engine == "mysql"              ? "mysql8.0"   :
               var.engine == "aurora-postgresql"  ? "aurora-postgresql15" :
               var.engine == "aurora-mysql"       ? "aurora-mysql8.0" :
               "postgres15"
}

resource "aws_db_subnet_group" "this" {
  name = "${var.name}-subnets"
  subnet_ids = var.subnet_ids
  tags = { Name = "${var.name}-subnets" }
}

resource "aws_security_group" "this" {
  name = "${var.name}-sg"
  description = "DB access"
  vpc_id = var.vpc_id

  ingress {
    from_port = var.port
    to_port = var.port
    protocol = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "DB port"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-sg" }
}

# Parameter groups
resource "aws_db_parameter_group" "instance" {
  count  = var.use_aurora ? 0 : 1
  name   = "${var.name}-pg"
  family = local.family

  dynamic "parameter" {
    for_each = merge({
      for k, v in {
        "log_statement" = local.is_pg ? "none" : null
        "max_connections" = local.is_pg ? "200" : null
        "work_mem" = local.is_pg ? "65536" : null
      } : k => v if v != null
    }, var.parameter_overrides)
    content {
      name  = parameter.key
      value = parameter.value
    }
  }
}

resource "aws_rds_cluster_parameter_group" "cluster" {
  count  = var.use_aurora ? 1 : 0
  name   = "${var.name}-cluster-pg"
  family = local.family

  dynamic "parameter" {
    for_each = merge({
      for k, v in {
        "log_statement" = local.is_pg ? "none" : null
        "max_connections" = local.is_pg ? "200" : null
        "work_mem" = local.is_pg ? "65536" : null
      } : k => v if v != null
    }, var.parameter_overrides)
    content {
      name  = parameter.key
      value = parameter.value
    }
  }
}
