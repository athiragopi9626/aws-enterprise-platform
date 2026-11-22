
# Private Elastic Container Registry repository.
# ECS Fargate will pull the application image from here.
resource "aws_ecr_repository" "this" {
  name = var.repository_name

  # Prevent an existing image tag from being overwritten.
  # Use unique image tags such as Git commit SHA.
  image_tag_mutability = "IMMUTABLE"

  # Encrypt images at rest using AWS-managed encryption.
  encryption_configuration {
    encryption_type = "AES256"
  }

  # Scan images when they are pushed to the repository.
  image_scanning_configuration {
    scan_on_push = true
  }

  # Prevent accidental repository deletion through Terraform
  # while it still contains container images.
  force_delete = false

  tags = merge(var.tags, {
    Name = var.repository_name
  })
}

# Automatically expire older untagged images.
# This helps reduce storage costs from incomplete or old builds.
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images older than 7 days"

        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}
