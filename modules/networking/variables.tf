variable "name" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "availability_zones" {
  type = list(string)
  validation {
    condition     = length(var.availability_zones) == 2 && length(distinct(var.availability_zones)) == 2
    error_message = "Exactly two distinct Availability Zones are required."
  }
}
variable "enable_nat_gateways" {
  type    = bool
  default = false
}
