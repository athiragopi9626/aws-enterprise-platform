
variable "name" {
  description = "Name prefix for ALB resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the existing VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs in at least two Availability Zones."
  type        = list(string)

  validation {
    condition     = length(distinct(var.public_subnet_ids)) >= 2
    error_message = "Provide at least two distinct public subnet IDs."
  }
}

variable "ecs_security_group_id" {
  description = "Security group ID assigned to ECS Fargate tasks."
  type        = string
}

variable "container_port" {
  description = "Port on which the ECS application listens."
  type        = number
  default     = 8080

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "Container port must be between 1 and 65535."
  }
}

variable "health_check_path" {
  description = "HTTP endpoint used to check application health."
  type        = string
  default     = "/health"
}

variable "enable_deletion_protection" {
  description = "Prevent accidental ALB deletion when enabled."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to AWS resources."
  type        = map(string)
  default     = {}
}
