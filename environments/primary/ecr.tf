
# Private container image repository for the ECS application.
module "ecr" {
  source = "../../modules/ecr"

  repository_name = "aep-primary-app"

  tags = {
    Environment = "primary"
    ManagedBy   = "Terraform"
    Project     = "aws-enterprise-platform"
    Owner       = "portfolio"
  }
}
