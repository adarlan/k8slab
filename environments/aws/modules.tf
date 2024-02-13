
module "aws-vpc" {
  source                = "./../../cloud-network/aws-vpc"

  cluster_name          = var.cluster_name
  vpc_cidr_block        = var.vpc_cidr_block
  tags                  = var.tags
  max_az_count          = var.max_az_count
  max_nat_gateway_count = var.max_nat_gateway_count
}
