
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  available_az_count   = length(data.aws_availability_zones.available)
  az_count             = min(var.max_az_count, local.available_az_count)
  public_subnet_count  = local.az_count
  private_subnet_count = local.az_count
  nat_gateway_count    = min(var.max_nat_gateway_count, local.private_subnet_count)
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.cluster_name}/vpc" })
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { Name = "${var.cluster_name}/internet-gateway" })
}

resource "aws_eip" "nat_eip" {
  count  = local.nat_gateway_count
  domain = "vpc"
  tags   = merge(var.tags, { Name = format("%s/%s/%s", var.cluster_name, "nat-eip", data.aws_availability_zones.available.names[count.index]) })
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = local.nat_gateway_count
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge(var.tags, { Name = format("%s/%s/%s", var.cluster_name, "nat-gateway", data.aws_availability_zones.available.names[count.index]) })
  depends_on    = [aws_internet_gateway.internet_gateway]
}

resource "aws_subnet" "public" {
  count                   = local.public_subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    var.tags,
    {
      "Name"                                      = format("%s/%s/%s", var.cluster_name, "public-subnet", data.aws_availability_zones.available.names[count.index])
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      "kubernetes.io/role/internal-elb"           = "1"
    }
  )
}

resource "aws_subnet" "private" {
  count             = local.private_subnet_count
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, local.public_subnet_count + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    var.tags,
    {
      "Name"                                      = format("%s/%s/%s", var.cluster_name, "private-subnet", data.aws_availability_zones.available.names[count.index])
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      "kubernetes.io/role/internal-elb"           = "1"
    }
  )
}

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
  tags = merge(var.tags, { Name = format("%s/%s/%s", var.cluster_name, "private-route-table", data.aws_availability_zones.available.names[count.index]) })
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
