resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0
  cluster_identifier = "${var.name}-cluster"
  engine = var.engine
  engine_version = var.engine_version
  database_name = var.db_name
  master_username = var.master_username
  master_password = var.master_password
  port = var.port
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster[0].name
  backup_retention_period = var.backup_retention_days
  deletion_protection = var.deletion_protection
  skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "this" {
  count = var.use_aurora ? 1 : 0
  identifier= "${var.name}-writer-0"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class = var.instance_class
  engine = var.engine
  engine_version = var.engine_version
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.this.name
}
