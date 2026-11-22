variable "aws_region" {
  description = "Region for the application infrastructure (can differ from S3 state bucket region)."
  type        = string
  default     = "eu-west-1"
}
variable "owner_tag" {
  type    = string
  default = "portfolio"
}
variable "vpc_cidr" {
  type    = string
  default = "10.42.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "Provide a valid IPv4 CIDR."
  }
}
variable "enable_nat_gateways" {
  description = "Off by default to avoid NAT hourly charges; needed for general outbound Internet from private subnets."
  type        = bool
  default     = false
}
