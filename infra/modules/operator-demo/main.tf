terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "app_name" {
  type    = string
  default = "operator-demo"
}

variable "app_env" {
  type = string
}

variable "image" {
  type = string
}

variable "db" {
  type = object({
    endpoint = string
    credentials = object({
      arn = string
    })
    name = string
  })
}

variable "role" {
  type = object({
    arn = string
  })
}

variable "network_configuration" {
  type = object({
    region = string
    vpc = object({
      id = string
    })
    subnets         = list(string),
    security_groups = list(string),
    load_balancer_target_groups = list(object({
      arn  = string,
      port = number
    }))
  })
}

variable "env" {
  type    = map(string)
  default = {}
}

variable "instance_count_min" {
  type    = number
  default = 1
}

variable "instance_count_max" {
  type    = number
  default = 8
}


resource "aws_cloudwatch_log_group" "this" {
  name = "${var.app_env}-${var.app_name}"

  tags = {
    Environment = "${var.app_env}"
  }
}

resource "aws_ecs_cluster" "this" {
  name = "${var.app_env}-${var.app_name}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = var.app_env
  }
}

resource "aws_ecs_service" "this" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.service.arn

  launch_type                       = "FARGATE"
  desired_count                     = 2
  health_check_grace_period_seconds = 30

  network_configuration {
    subnets          = var.network_configuration.subnets
    security_groups  = var.network_configuration.security_groups
    assign_public_ip = false
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.app_env

    service {
      client_alias {
        port = 80
      }
      port_name = var.app_name
    }
  }

  dynamic "load_balancer" {
    for_each = var.network_configuration.load_balancer_target_groups
    content {
      target_group_arn = load_balancer.value.arn
      container_port   = load_balancer.value.port
      container_name   = var.app_name
    }
  }

  tags = {
    Environment = var.app_env
  }

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = "${var.app_env}-${var.app_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 512
  memory = 1024

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = var.role.arn

  container_definitions = jsonencode([{
    name      = var.app_name
    image     = var.image
    essential = true
    portMappings = [{
      containerPort = 9400
      appProtocol   = "http"
      name          = var.app_name
    }]
    environment = concat([{
      name  = "SERVER_PORT"
      value = "9400"
      }, {
      name  = "SPRING_R2DBC_URL"
      value = "r2dbc:postgresql://${var.db.endpoint}:5432/${var.db.name}"
      }], [for name, value in var.env : {
      name  = name
      value = value
    }])
    secrets = [{
      name      = "SPRING_R2DBC_USERNAME",
      valueFrom = "${var.db.credentials.arn}:username::"
      }, {
      name      = "SPRING_R2DBC_PASSWORD",
      valueFrom = "${var.db.credentials.arn}:password::"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.this.name
        "awslogs-region"        = var.network_configuration.region
        "awslogs-stream-prefix" = "ecs"
        "mode"                  = "non-blocking"
        "max-buffer-size"       = "1m"
      }
    }
    healthcheck = {
      command  = ["CMD-SHELL", "exit 0"]
      interval = 30
      retries  = 3
      timeout  = 5
    }
    mountPoints    = []
    systemControls = []
    volumesFrom    = []
  }])

  tags = {
    Environment = var.app_env
  }
}

resource "aws_appautoscaling_policy" "this_memory" {
  name               = "${aws_ecs_cluster.this.name}-${aws_ecs_service.this.name}-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80

    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "this_cpu" {
  name               = "${aws_ecs_cluster.this.name}-${aws_ecs_service.this.name}-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 80

    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_target" "this" {
  max_capacity       = var.instance_count_max
  min_capacity       = var.instance_count_min
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
