resource "aws_db_subnet_group" "this" {
  name = "${var.name}-db-subnets"
  subnet_ids = var.private_subnet_ids
}


resource "aws_security_group" "db" {
  name = "${var.name}-db-sg"
  description = "DB access"
  vpc_id = var.vpc_id
  ingress { from_port = 5432 to_port = 5432 protocol = "tcp" cidr_blocks = ["10.0.0.0/8"] }
  egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
}