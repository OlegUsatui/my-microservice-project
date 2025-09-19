variable "name" { type = string }
variable "cluster_version" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids" { type = list(string) }
variable "node_group_desired" { type = number }
variable "node_group_max" { type = number }
variable "node_instance_types" { type = list(string) }