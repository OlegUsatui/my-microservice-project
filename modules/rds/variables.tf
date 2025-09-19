variable "name" {
  type = string
  description = "Name prefix for RDS resources"
}

variable "use_aurora" {
  type = bool
  description = "If true, create Aurora cluster; otherwise single RDS instance"
  default = false
}

variable "engine" {
  type = string
  description = "Engine type: postgres | mysql | aurora-postgresql | aurora-mysql"
  default = "postgres"
}

variable "engine_version" {
  type = string
  description = "Engine version"
  default = null
}

variable "instance_class" {
  type = string
  description = "DB instance class"
  default = "db.t4g.medium"
}

variable "db_name" {
  type = string
  description = "Initial database name"
  default = "appdb"
}

variable "master_username" {
  type = string
  description = "Master username"
  default = "dbadmin"
}

variable "master_password" {
  type = string
  description = "Master password"
  sensitive = true
}

variable "port" {
  type = number
  description = "DB port (5432 for Postgres, 3306 for MySQL)"
  default = 5432
}

variable "multi_az" {
  type = bool
  description = "Multi-AZ for single RDS instance"
  default = false
}

variable "storage_gb" {
  type = number
  description = "Allocated storage for single RDS instance"
  default = 20
}

variable "storage_type" {
  type = string
  description = "Storage type for single RDS instance (gp2|gp3|io1)"
  default = "gp3"
}

variable "backup_retention_days" {
  type = number
  description = "Automated backup retention days"
  default = 1
}

variable "deletion_protection" {
  type = bool
  description = "Enable deletion protection"
  default = false
}

variable "vpc_id" {
  type = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type = list(string)
  description = "Private subnet IDs for DB subnet group"
}

variable "allowed_cidr_blocks" {
  type = list(string)
  description = "CIDR blocks allowed to connect to the DB"
  default = []
}

variable "parameter_overrides" {
  type = map(string)
  description = "Map of parameter overrides for the parameter group"
  default = {}
}
