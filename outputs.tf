output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id

  depends_on = [aws_route_table_association.public, aws_route_table_association.private]
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.this.cidr_block

  depends_on = [aws_route_table_association.public, aws_route_table_association.private]
}

output "nat_gateway_enabled" {
  value = var.enable_nat_gateway
}
