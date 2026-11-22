locals {
  # /16 -> /24. Non-overlapping public and private subnets, two AZs.
  azs = { for i, az in var.availability_zones : tostring(i) => az }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = var.name }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-igw" }
}

resource "aws_subnet" "public" {
  for_each                = local.azs
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, tonumber(each.key))
  map_public_ip_on_launch = false
  tags                    = { Name = "${var.name}-public-${each.value}", Tier = "public" }
}

resource "aws_subnet" "private" {
  for_each                = local.azs
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, tonumber(each.key) + 10)
  map_public_ip_on_launch = false
  tags                    = { Name = "${var.name}-private-${each.value}", Tier = "private" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = { Name = "${var.name}-public" }
}

resource "aws_route_table_association" "public" {
  for_each       = local.azs
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# Optional HA NAT: one NAT Gateway per AZ. Disabled for low-cost foundation deployment.
resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateways ? local.azs : {}
  domain   = "vpc"
  tags     = { Name = "${var.name}-nat-${each.value}" }
}

resource "aws_nat_gateway" "this" {
  for_each      = var.enable_nat_gateways ? local.azs : {}
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  depends_on    = [aws_internet_gateway.this]
  tags          = { Name = "${var.name}-nat-${each.value}" }
}

resource "aws_route_table" "private" {
  for_each = local.azs
  vpc_id   = aws_vpc.this.id
  dynamic "route" {
    for_each = var.enable_nat_gateways ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.this[each.key].id
    }
  }
  tags = { Name = "${var.name}-private-${each.value}" }
}

resource "aws_route_table_association" "private" {
  for_each       = local.azs
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
