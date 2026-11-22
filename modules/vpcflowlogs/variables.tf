
variable "name" {
  description = "Name prefix for flow log resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to monitor."
  type        = string
}

variable "retention_in_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
