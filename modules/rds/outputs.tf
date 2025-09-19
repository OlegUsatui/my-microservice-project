output "security_group_id" {
  value = aws_security_group.this.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.this.name
}

output "instance_endpoint" {
  value = try(aws_db_instance.this[0].endpoint, null)
}

output "writer_endpoint" {
  value = try(aws_rds_cluster.this[0].endpoint, null)
}

output "reader_endpoint" {
  value = try(aws_rds_cluster.this[0].reader_endpoint, null)
}
