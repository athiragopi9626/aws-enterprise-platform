output "vpc_id" {
  value = module.networking.vpc_id
}
output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}
output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}
output "availability_zones" {
  value = module.networking.availability_zones
}
output "nat_gateway_ids" {
  value = module.networking.nat_gateway_ids
}


# Public DNS name for testing the application.
output "alb_dns_name" {
  description = "DNS name of the public Application Load Balancer."
  value       = module.application_lb.alb_dns_name
}

# ECS will use this target group when creating its service.
output "ecs_target_group_arn" {
  description = "Target group ARN used by the ECS service."
  value       = module.application_lb.target_group_arn
}

