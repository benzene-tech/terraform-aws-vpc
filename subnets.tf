# Private
resource "aws_subnet" "private" {
  for_each = toset(data.aws_availability_zones.this.names)

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.subnet_cidrs.private[each.key]
  availability_zone = each.value

  tags = merge(var.tags, var.subnet_tags.private, {
    Name = "${var.name}-private-${each.key}"
  })
}

resource "aws_nat_gateway" "this" {
  vpc_id            = aws_vpc.this.id
  availability_mode = "regional"

  tags = merge(var.tags, {
    Name = var.name
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# Protected
resource "aws_subnet" "protected" {
  for_each = toset(data.aws_availability_zones.this.names)

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.subnet_cidrs.protected[each.key]
  availability_zone = each.value

  tags = merge(var.tags, var.subnet_tags.protected, {
    Name = "${var.name}-protected-${each.key}"
  })
}

resource "aws_route_table" "protected" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_route_table_association" "protected" {
  for_each = aws_subnet.protected

  subnet_id      = each.value.id
  route_table_id = aws_route_table.protected.id
}

# Public
resource "aws_subnet" "public" {
  for_each = toset(data.aws_availability_zones.this.names)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.subnet_cidrs.public[each.key]
  availability_zone       = each.value
  map_public_ip_on_launch = "true"

  tags = merge(var.tags, var.subnet_tags.public, {
    Name = "${var.name}-public-${each.key}"
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

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
