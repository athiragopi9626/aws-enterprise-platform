variable "name" { type = string }
variable "aws_region" { type = string }
variable "private_subnet_ids" {
  type = list(string)
  validation {
    condition     = length(distinct(var.private_subnet_ids)) >= 2
    error_message = "Provide two private subnets in different AZs."
  }
}
variable "ecs_security_group_id" { type = string }
variable "target_group_arn" { type = string }
variable "repository_url" { type = string }
variable "image_tag" {
  type = string
  validation {
    condition     = can(regex("^[0-9a-f]{40}$", var.image_tag))
    error_message = "image_tag must be a 40-character Git commit SHA."
  }
}
variable "container_port" { type = number
  default = 8080 }
variable "desired_count" { type = number
  default = 2 }
variable "enable_container_insights" { type = bool
  default = false }
variable "tags" { type = map(string)
  default = {} }
