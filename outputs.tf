output "cidr_block" {
  description = "VPC CIDR"
  value       = aws_vpc.this.cidr_block

  depends_on = [aws_route_table_association.public, aws_route_table_association.private]
}

output "id" {
  description = "VPC ID"
  value       = aws_vpc.this.id

  depends_on = [aws_route_table_association.public, aws_route_table_association.private]
}

output "private_subnets" {
  description = "List of private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]

  depends_on = [aws_route_table_association.private]
}

output "protected_subnets" {
  description = "List of protected subnets"
  value       = [for subnet in aws_subnet.protected : subnet.id]

  depends_on = [aws_route_table_association.protected]
}

output "public_subnets" {
  description = "List of public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]

  depends_on = [aws_route_table_association.public]
}

output "nat_gateway_address" {
  description = "Public IP addresses of the regional NAT gateway (one per availability zone)"
  value       = [for addr in aws_nat_gateway.this.regional_nat_gateway_address : addr.public_ip]
}

output "ip" {
  description = "Total IP capacity by subnet type across all availability zones"
  value = {
    private   = local.subnet_size.private * local.availability_zones_count
    protected = local.subnet_size.protected * local.availability_zones_count
    public    = local.subnet_size.public * local.availability_zones_count
  }
}
