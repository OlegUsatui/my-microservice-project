resource "aws_db_instance" "this" {
  count = var.use_aurora ? 0 : 1
  identifier = var.name
  engine = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  db_name = var.db_name
  username = var.master_username
  password = var.master_password
  port = var.port
  multi_az = var.multi_az
  allocated_storage = var.storage_gb
  storage_type = var.storage_type
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name = aws_db_parameter_group.instance[0].name
  deletion_protection = var.deletion_protection
  backup_retention_period = var.backup_retention_days
  skip_final_snapshot = true
  publicly_accessible = false
}
