resource "aws_db_instance" "this" {
  count = var.use_aurora ? 0 : 1
  identifier = "${var.name}-rds"
  engine = var.engine
  engine_version = var.engine == "postgres" ? "16" : "8.0"
  instance_class = "db.t3.micro"
  username = var.db_username
  password = var.db_password
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  allocated_storage = 20
  skip_final_snapshot = true
}