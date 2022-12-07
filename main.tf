locals {
  availability_zones_count = length(data.aws_availability_zones.available.names)
  subnet_bits              = ceil(log(local.availability_zones_count * 2, 2))
  public_cidr_subnets      = { for net in range(0, local.availability_zones_count) : data.aws_availability_zones.available.names[net] => cidrsubnet(var.vpc_cidr_block, local.subnet_bits, net) }
  private_cidr_subnets     = { for net in range(local.availability_zones_count, local.availability_zones_count * 2) : data.aws_availability_zones.available.names[net % local.availability_zones_count] => cidrsubnet(var.vpc_cidr_block, local.subnet_bits, net) }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = var.name_prefix
  }
}

# Public
resource "aws_subnet" "public" {
  for_each = toset(data.aws_availability_zones.available.names)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_cidr_subnets[each.value]
  map_public_ip_on_launch = "true"
  availability_zone       = each.value

  tags = merge({
    Name = "${var.name_prefix}_${each.value}_public"
  }, var.additional_public_subnet_tags)
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.name_prefix
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name_prefix}_public_route_table"
  }
}

resource "aws_route_table_association" "public" {
  for_each = toset(data.aws_availability_zones.available.names)

  subnet_id      = aws_subnet.public[each.value].id
  route_table_id = aws_route_table.public.id
}

# Private
resource "aws_subnet" "private" {
  for_each = toset(data.aws_availability_zones.available.names)

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_cidr_subnets[each.value]
  availability_zone = each.value

  tags = merge({
    Name = "${var.name_prefix}_${each.value}_private"
  }, var.additional_private_subnet_tags)
}

resource "aws_eip" "nat_gateway" {
  count = var.enable_nat_gateway ? 1 : 0

  vpc = true

  tags = {
    Name = "${var.name_prefix}_nat_gateway_eip"
  }
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat_gateway[count.index].id
  subnet_id     = aws_subnet.public[data.aws_availability_zones.available.names[0]].id

  tags = {
    Name = var.name_prefix
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [
      {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.this[0].id
      }
    ] : []
    content {
      cidr_block     = route.value["cidr_block"]
      nat_gateway_id = route.value["nat_gateway_id"]
    }
  }

  tags = {
    Name = "${var.name_prefix}_private_route_table"
  }
}

resource "aws_route_table_association" "private" {
  for_each = toset(data.aws_availability_zones.available.names)

  subnet_id      = aws_subnet.private[each.value].id
  route_table_id = aws_route_table.private.id
}
