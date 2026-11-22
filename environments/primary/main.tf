data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "networking" {
  source              = "../../modules/networking"
  name                = "aep-primary"
  vpc_cidr            = var.vpc_cidr
  availability_zones  = slice(data.aws_availability_zones.available.names, 0, 2)
  enable_nat_gateways = var.enable_nat_gateways
}
