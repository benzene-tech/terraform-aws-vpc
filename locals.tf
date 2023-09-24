locals {
  availability_zones_count = length(data.aws_availability_zones.this.names)
  subnet_count             = var.subnet_count != null ? (var.subnet_count <= local.availability_zones_count ? var.subnet_count : local.availability_zones_count) : local.availability_zones_count
  subnet_bits              = ceil(log(local.subnet_count * 2, 2))
  subnet_num               = pow(2, local.subnet_bits)
  public_cidr_subnets      = [for net in range(0, ceil(local.subnet_num / 2)) : cidrsubnet(var.cidr_block, local.subnet_bits, net)]
  private_cidr_subnets     = [for net in range(ceil(local.subnet_num / 2), local.subnet_num) : cidrsubnet(var.cidr_block, local.subnet_bits, net)]
}
