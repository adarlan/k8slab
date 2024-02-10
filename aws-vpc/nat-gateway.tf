
resource "aws_eip" "nat_eip" {
  count  = local.nat_gateway_count
  domain = "vpc"
  tags   = merge(var.tags, { Name = format("%s/%s/%s", var.cluster_name, "nat-eip", local.az_names[count.index]) })
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = local.nat_gateway_count
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge(var.tags, { Name = format("%s/%s/%s", var.cluster_name, "nat-gateway", local.az_names[count.index]) })
  depends_on    = [aws_internet_gateway.internet_gateway]
}
