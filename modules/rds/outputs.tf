output "endpoint" {
  value = var.use_aurora ? try(aws_rds_cluster.this[0].endpoint, null) : try(aws_db_instance.this[0].address, null)
}