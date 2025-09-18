variable "vpc_name" { type = string }
variable "vpc_cidr_block" { type = string }
variable "availability_zones" { type = list(string) }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
