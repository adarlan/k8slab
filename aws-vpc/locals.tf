
locals {
  available_az_count   = length(data.aws_availability_zones.available)
  az_count             = min(var.max_az_count, local.available_az_count)
  public_subnet_count  = local.az_count
  private_subnet_count = local.az_count
  nat_gateway_count    = min(var.max_nat_gateway_count, local.private_subnet_count)
  az_names             = data.aws_availability_zones.available.names
}
