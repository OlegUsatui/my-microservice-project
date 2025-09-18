resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain = "vpc"

  depends_on = [aws_internet_gateway.igw]

  tags = { Name = "${var.vpc_name}-nat-eip-${each.key}" }
}

resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public
  subnet_id = each.value.id
  allocation_id = aws_eip.nat[each.key].id

  tags = { Name = "${var.vpc_name}-nat-${each.key}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.vpc_name}-public-rt" }
}

resource "aws_route" "public_internet_access" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public
  subnet_id = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.vpc_name}-private-rt-${each.key}" }
}

resource "aws_route" "private_to_internet" {
  for_each = aws_route_table.private
  route_table_id = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private
  subnet_id = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
