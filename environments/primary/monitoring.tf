
module "monitoring" {
  source = "../../modules/monitoring"

  name         = "aep-primary"
  cluster_name = module.ecs_fargate.cluster_name
  service_name = module.ecs_fargate.service_name

  load_balancer_arn_suffix = module.application_lb.alb_arn_suffix
  target_group_arn_suffix  = module.application_lb.target_group_arn_suffix

  # Leave blank until you want email notifications.
  notification_email = ""

  tags = {
    Environment = "primary"
    ManagedBy   = "Terraform"
    Project     = "aws-enterprise-platform"
  }
}
