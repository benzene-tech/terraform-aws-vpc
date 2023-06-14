# Public
resource "aws_subnet" "public" {
  for_each = toset(data.aws_availability_zones.this.names)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_cidr_subnets[each.value]
  map_public_ip_on_launch = "true"
  availability_zone       = each.value

  tags = merge({
    Name = "${var.name_prefix}_public"
  }, var.public_subnet_tags)
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
    Name = "${var.name_prefix}_public"
  }
}

resource "aws_route_table_association" "public" {
  for_each = toset(data.aws_availability_zones.this.names)

  subnet_id      = aws_subnet.public[each.value].id
  route_table_id = aws_route_table.public.id
}


# Private
resource "aws_subnet" "private" {
  for_each = toset(data.aws_availability_zones.this.names)

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_cidr_subnets[each.value]
  availability_zone = each.value

  tags = merge({
    Name = "${var.name_prefix}_private"
  }, var.private_subnet_tags)
}

resource "aws_eip" "nat_gateway" {
  count = var.enable_nat_gateway ? 1 : 0

  tags = {
    Name = "${var.name_prefix}_nat_gateway"
  }
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat_gateway[count.index].id
  subnet_id     = aws_subnet.public[data.aws_availability_zones.this.names[0]].id

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
    Name = "${var.name_prefix}_private"
  }
}

resource "aws_route_table_association" "private" {
  for_each = toset(data.aws_availability_zones.this.names)

  subnet_id      = aws_subnet.private[each.value].id
  route_table_id = aws_route_table.private.id
}
