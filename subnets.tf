# Public
resource "aws_subnet" "public" {
  count = length(local.public_cidr_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_cidr_subnets[count.index]
  availability_zone       = data.aws_availability_zones.this.names[count.index % local.availability_zones_count]
  map_public_ip_on_launch = "true"

  tags = merge(var.tags, var.subnet_tags.public, {
    Name = var.name
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_route_table_association" "public" {
  count = length(local.public_cidr_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# Private
resource "aws_subnet" "private" {
  count = length(local.private_cidr_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_cidr_subnets[count.index]
  availability_zone = data.aws_availability_zones.this.names[count.index % local.availability_zones_count]

  tags = merge(var.tags, var.subnet_tags.private, {
    Name = var.name
  })
}

resource "aws_eip" "this" {
  count = var.enable_nat_gateway ? local.availability_zones_count : 0

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? local.availability_zones_count : 0

  allocation_id = aws_eip.this[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name = var.name
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  count = local.availability_zones_count

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [aws_nat_gateway.this[count.index].id] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = route.value
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_route_table_association" "private" {
  count = length(local.private_cidr_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index % local.availability_zones_count].id
}
