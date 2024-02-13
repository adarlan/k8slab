
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  # Must be enabled for EFS
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.cluster_name}/vpc" })
}
