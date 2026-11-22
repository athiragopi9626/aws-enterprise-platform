
variable "name" {
  description = "Name prefix for ECS resources."
  type        = string
}

variable "aws_region" {
  description = "AWS Region where ECS resources are deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS Fargate tasks."
  type        = list(string)

  validation {
    condition     = length(distinct(var.private_subnet_ids)) >= 2
    error_message = "Provide at least two distinct private subnet IDs."
  }
}

variable "ecs_security_group_id" {
  description = "Security group ID assigned to ECS tasks."
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the Application Load Balancer target group."
  type        = string
}

variable "repository_url" {
  description = "URL of the Amazon ECR repository."
  type        = string
}

variable "image_tag" {
  description = "Immutable Docker image tag based on the Git commit SHA."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{40}$", var.image_tag))
    error_message = "image_tag must be a 40-character Git commit SHA."
  }
}

variable "container_port" {
  description = "Application container port."
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Number of ECS Fargate tasks."
  type        = number
  default     = 2
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common AWS resource tags."
  type        = map(string)
  default     = {}
}
