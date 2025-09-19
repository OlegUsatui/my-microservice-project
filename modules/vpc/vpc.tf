resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = { Name = var.name }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
}


resource "aws_subnet" "public" {
  for_each = toset(var.public_subnets)
  vpc_id = aws_vpc.this.id
  cidr_block = each.value
  map_public_ip_on_launch = true
  availability_zone = element(var.azs, index(var.public_subnets, each.value))
}


resource "aws_subnet" "private" {
  for_each = toset(var.private_subnets)
  vpc_id = aws_vpc.this.id
  cidr_block = each.value
  availability_zone = element(var.azs, index(var.private_subnets, each.value))
}