variable "db_master_password" {
  description = "Master password for RDS/Aurora"
  type = string
  sensitive = true
}
