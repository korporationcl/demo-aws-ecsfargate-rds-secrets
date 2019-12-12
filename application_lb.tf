# Application Load Balancer configuration

resource "aws_security_group" "lb" {
  name        = "lb"
  description = "Application LB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_alb" "lb" {
  name            = "lb"
  subnets         = module.vpc.public_subnets
  security_groups = [
    aws_security_group.lb.id,
  ]

  tags = var.tags
}

resource "aws_alb_target_group" "application" {
  name        = "application"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.lb.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.application.id
    type             = "forward"
  }
}

output "lb_endpoint" {
  description = "Load Balancer DNS endpoint"
  value       = aws_alb.lb.dns_name
}
