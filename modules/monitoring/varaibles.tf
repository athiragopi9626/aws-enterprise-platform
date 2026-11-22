
variable "name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "load_balancer_arn_suffix" {
  type = string
}

variable "target_group_arn_suffix" {
  type = string
}

variable "notification_email" {
  description = "Optional email for CloudWatch alarm notifications."
  type        = string
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
