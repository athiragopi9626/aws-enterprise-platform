
variable "name" {
  description = "Name prefix for VPC endpoint resources."
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC ID."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs in two Availability Zones."
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "Route tables associated with private subnets."
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID of the ECS Fargate tasks."
  type        = string
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}
