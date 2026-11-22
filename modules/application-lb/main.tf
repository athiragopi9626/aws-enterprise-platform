
# Security group for the internet-facing Application Load Balancer.
# The ALB accepts incoming HTTP requests and forwards them to ECS tasks.
resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-"
  description = "Security group for the public Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-alb"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Allow inbound HTTP from internet clients.
# HTTP is used for the initial lab; production should use HTTPS.
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.alb.id

  description = "Allow HTTP from internet clients"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_ipv4   = "0.0.0.0/0"
}

# Allow the ALB to connect only to the ECS application port.
# The destination security group must also allow traffic from this ALB.
resource "aws_vpc_security_group_egress_rule" "ecs" {
  security_group_id = aws_security_group.alb.id

  description                  = "Forward requests to ECS tasks"
  ip_protocol                  = "tcp"
  from_port                    = var.container_port
  to_port                      = var.container_port
  referenced_security_group_id = var.ecs_security_group_id
}

# Permit application traffic to ECS tasks only from the ALB.
# ECS tasks remain in private subnets without public IP addresses.
resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id = var.ecs_security_group_id

  description                  = "Application traffic from ALB only"
  ip_protocol                  = "tcp"
  from_port                    = var.container_port
  to_port                      = var.container_port
  referenced_security_group_id = aws_security_group.alb.id
}

# Internet-facing ALB spanning two public subnets.
# AWS manages ALB nodes across the enabled Availability Zones.
resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb.id]
  subnets         = var.public_subnet_ids

  # Prevent deletion by Terraform only when intentionally enabled.
  # Keep false for this cost-conscious portfolio lab.
  enable_deletion_protection = var.enable_deletion_protection

  # Drop invalid HTTP headers instead of forwarding them.
  drop_invalid_header_fields = true

  tags = merge(var.tags, {
    Name = "${var.name}-alb"
  })
}

# Target group for ECS Fargate tasks.
# Fargate uses awsvpc networking, so targets are registered by IP.
resource "aws_lb_target_group" "ecs" {
  name        = "${var.name}-ecs"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  # Check the application health endpoint.
  # The ECS container must return HTTP 200 from /health.
  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  # Allow in-flight requests to complete during task replacement.
  deregistration_delay = 30

  tags = merge(var.tags, {
    Name = "${var.name}-ecs"
  })
}

# Public HTTP listener.
# Requests arriving on port 80 are forwarded to the ECS target group.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }

  tags = var.tags
}
