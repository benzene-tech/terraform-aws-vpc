locals {
  availability_zones_count = length(data.aws_availability_zones.this.names)
  subnet_bits              = ceil(log(local.availability_zones_count * 2, 2))
  public_cidr_subnets      = { for net in range(0, local.availability_zones_count) : data.aws_availability_zones.this.names[net] => cidrsubnet(var.cidr_block, local.subnet_bits, net) }
  private_cidr_subnets     = { for net in range(local.availability_zones_count, local.availability_zones_count * 2) : data.aws_availability_zones.this.names[net % local.availability_zones_count] => cidrsubnet(var.cidr_block, local.subnet_bits, net) }
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = var.name_prefix
  }
}
