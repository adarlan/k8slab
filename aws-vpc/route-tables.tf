
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = merge(var.tags, { Name = "${var.cluster_name}/public-route-table" })
}

resource "aws_route_table" "private" {
  count  = local.nat_gateway_count
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }
  tags = merge(var.tags, { Name = format("%s/%s/%s", var.cluster_name, "private-route-table", local.az_names[count.index]) })
}

resource "aws_route_table_association" "public" {
  count          = local.public_subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = local.nat_gateway_count == 0 ? 0 : local.private_subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index % local.nat_gateway_count].id
}
