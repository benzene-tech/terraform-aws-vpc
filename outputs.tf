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

output "public_subnets" {
  description = "List of public subnets"
  value       = aws_subnet.public[*].id

  depends_on = [aws_route_table_association.public]
}

output "private_subnets" {
  description = "List of private subnets"
  value       = aws_subnet.private[*].id

  depends_on = [aws_route_table_association.private]
}

output "nat_gateway_enabled" {
  description = "Flag to check if NAT gateway is available in the VPC"
  value       = var.enable_nat_gateway
}
