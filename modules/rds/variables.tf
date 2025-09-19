variable "name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "use_aurora" { type = bool }
variable "engine" { type = string default = "postgres" }
variable "db_username" { type = string }
variable "db_password" { type = string }