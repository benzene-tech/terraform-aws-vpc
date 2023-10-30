locals {
  availability_zones_count = var.availability_zones_count != null ? (var.availability_zones_count <= length(data.aws_availability_zones.this.names) ? var.availability_zones_count : length(data.aws_availability_zones.this.names)) : length(data.aws_availability_zones.this.names)
  subnet_bits              = ceil(log(local.availability_zones_count * 2, 2))
  subnet_num               = pow(2, local.subnet_bits)
  public_cidr_subnets      = [for net in range(0, ceil(local.subnet_num / 2)) : cidrsubnet(var.cidr_block, local.subnet_bits, net)]
  private_cidr_subnets     = [for net in range(ceil(local.subnet_num / 2), local.subnet_num) : cidrsubnet(var.cidr_block, local.subnet_bits, net)]
}
