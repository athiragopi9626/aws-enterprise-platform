
# ECS tasks run in private subnets.
# The ALB ingress rule will be added in the next module.
resource "aws_security_group" "ecs_tasks" {
  name        = "aep-primary-ecs-tasks"
  description = "Security group for private ECS Fargate tasks"
  vpc_id      = module.networking.vpc_id

  tags = {
    Name        = "aep-primary-ecs-tasks"
    Environment = "primary"
    ManagedBy   = "Terraform"
    Project     = "aws-enterprise-platform"
  }
}

# Permit ECS tasks to establish outbound HTTPS connections.
# This is required for image pulls and log delivery.
resource "aws_vpc_security_group_egress_rule" "ecs_https" {
  security_group_id = aws_security_group.ecs_tasks.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv4   = "0.0.0.0/0"
  description = "Outbound HTTPS for AWS service endpoints"
}

module "vpc_endpoints" {
  source = "../../modules/vpc-endpoints"

  name                    = "aep-primary"
  vpc_id                  = module.networking.vpc_id
  private_subnet_ids      = module.networking.private_subnet_ids
  private_route_table_ids = module.networking.private_route_table_ids

  ecs_security_group_id = aws_security_group.ecs_tasks.id

  tags = {
    Environment = "primary"
    ManagedBy   = "Terraform"
    Project     = "aws-enterprise-platform"
    Owner       = "portfolio"
  }
}
