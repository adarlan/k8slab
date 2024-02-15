
resource "aws_subnet" "public" {
  count                   = local.public_subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    var.tags,
    {
      "Name"                                      = format("%s/%s/%s", var.cluster_name, "public-subnet", local.az_names[count.index])
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      "kubernetes.io/role/internal-elb"           = "1"
    }
  )
}

resource "aws_subnet" "private" {
  count                   = local.private_subnet_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, local.public_subnet_count + count.index)
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = false
  tags = merge(
    var.tags,
    {
      "Name"                                      = format("%s/%s/%s", var.cluster_name, "private-subnet", local.az_names[count.index])
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
      "kubernetes.io/role/internal-elb"           = "1"
    }
  )
}
