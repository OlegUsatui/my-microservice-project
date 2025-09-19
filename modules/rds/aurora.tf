resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0
  cluster_identifier = "${var.name}-aurora"
  engine = var.engine == "postgres" ? "aurora-postgresql" : "aurora-mysql"
  master_username = var.db_username
  master_password = var.db_password
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids= [aws_security_group.db.id]
  skip_final_snapshot = true
}


resource "aws_rds_cluster_instance" "instances" {
  count = var.use_aurora ? 2 : 0
  identifier = "${var.name}-aurora-${count.index}"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class = "db.t3.medium"
  engine = aws_rds_cluster.this[0].engine
}