
# Public Application Load Balancer for the ECS application.
# It distributes HTTP traffic to Fargate tasks in private subnets.
module "application_lb" {
  source = "../../modules/application-lb"

  name              = "aep-primary"
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids

  # Reuse the ECS task security group created during
  # the VPC endpoints implementation.
  ecs_security_group_id = aws_security_group.ecs_tasks.id

  # Application will listen on port 8080.
  container_port = 8080

  # ECS application must implement GET /health.
  health_check_path = "/health"

  # Disabled for the lab so resources can be destroyed
  # without requiring an extra configuration change.
  enable_deletion_protection = false

  tags = {
    Environment = "primary"
    ManagedBy   = "Terraform"
    Project     = "aws-enterprise-platform"
    Owner       = "portfolio"
  }
}
