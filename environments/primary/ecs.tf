module "ecs_fargate" {
  source = "../../modules/ecs-fargate"

  name                  = "aep-primary"
  aws_region            = "eu-west-1"
  private_subnet_ids    = module.networking.private_subnet_ids
  ecs_security_group_id = aws_security_group.ecs_tasks.id

  target_group_arn = module.application_lb.target_group_arn
  repository_url   = module.ecr.repository_url
  image_tag        = var.image_tag

  container_port = 8080
  desired_count  = 2

  enable_container_insights = false

  tags = {
    Environment = "primary"
    ManagedBy   = "Terraform"
    Project     = "aws-enterprise-platform"
  }

  depends_on = [
    module.application_lb,
    module.vpc_endpoints
  ]
}