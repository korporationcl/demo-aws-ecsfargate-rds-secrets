resource "aws_security_group" "ecs" {
  name        = "ecs"
  description = "ECS cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "main" {
  name = "main"
  tags = var.tags
}

resource "aws_ecs_task_definition" "service" {
  family                   = "service"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities = ["FARGATE"]

  container_definitions = <<EOF
[
  {
    "name": "webapp",
    "image": "${var.app_image}",
    "cpu": ${var.app_cpu},
    "memory": ${var.app_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/webapp",
          "awslogs-region": "${var.region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "secrets": [
      {
        "valueFrom": "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:db_user",
        "name": "DB_USERNAME"
      },
      {
        "valueFrom": "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:db_password",
        "name": "DB_PASSWORD"
      },
      {
        "valueFrom": "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:db_host",
        "name": "DB_HOST"
      },
      {
        "valueFrom": "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:db_name",
        "name": "DB_NAME"
      }
    ],
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "main" {
  name               = "webapp-service"
  cluster            = aws_ecs_cluster.main.id
  task_definition    = aws_ecs_task_definition.service.arn
  desired_count      = var.app_size
  launch_type        = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = module.vpc.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.application.id
    container_name   = "webapp"
    container_port   = var.app_port
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.app_autoscaling["min"]
  max_capacity       = var.app_autoscaling["max"]
}

resource "aws_appautoscaling_policy" "up" {
  name               = "webapp_scaleup"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}

resource "aws_appautoscaling_policy" "down" {
  name               = "webapp_scaledown"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "webapp_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }

  alarm_actions = [aws_appautoscaling_policy.up.arn]
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = "webapp_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }

  alarm_actions = [aws_appautoscaling_policy.down.arn]
}
