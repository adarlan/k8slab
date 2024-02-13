
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { Name = "${var.cluster_name}/internet-gateway" })
}
