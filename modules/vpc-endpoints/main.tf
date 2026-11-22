
# Get the current AWS Region and partition.
data "aws_region" "current" {}
data "aws_partition" "current" {}

# Allow ECS tasks to connect to private AWS service endpoints
# over HTTPS. Restrict access to the ECS task security group.
resource "aws_security_group" "endpoints" {
  name_prefix = "${var.name}-endpoints-"
  description = "Security group for private AWS service endpoints"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-endpoints"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Permit HTTPS traffic only from ECS tasks.
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id            = aws_security_group.endpoints.id
  referenced_security_group_id = var.ecs_security_group_id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "HTTPS from ECS Fargate tasks"
}

# No outbound rule is needed for the interface endpoint
# security group: security groups are stateful, so responses
# to permitted inbound connections are automatically allowed.

# ECR API, ECR Docker, and CloudWatch Logs interface endpoints.
# Each endpoint has an ENI in both private subnets for AZ resilience.
resource "aws_vpc_endpoint" "interface" {
  for_each = toset([
    "ecr.api",
    "ecr.dkr",
    "logs"
  ])

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.name}-${replace(each.value, ".", "-")}"
  })
}

# S3 gateway endpoint provides private S3 connectivity
# without NAT and without hourly gateway endpoint charges.
# ECR image layers are downloaded through S3.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = var.private_route_table_ids

  tags = merge(var.tags, {
    Name = "${var.name}-s3"
  })
}
