output "vpc_id" {
  value = aws_vpc.this.id
}
output "public_subnet_ids" {
  value = [for k in sort(keys(local.azs)) : aws_subnet.public[k].id]
}
output "private_subnet_ids" {
  value = [for k in sort(keys(local.azs)) : aws_subnet.private[k].id]
}
output "availability_zones" {
  value = var.availability_zones
}
output "nat_gateway_ids" {
  value = [for k in sort(keys(aws_nat_gateway.this)) : aws_nat_gateway.this[k].id]
}


# Expose private route table IDs so other modules
# can associate gateway endpoints with private routes.
output "private_route_table_ids" {
  description = "IDs of the private route tables across both AZs."

  value = [
    for rt in aws_route_table.private : rt.id
  ]
}
