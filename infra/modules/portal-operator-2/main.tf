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
  default = "portal-operator-2"
}

variable "app_env" {
  type = string
}

variable "domain" {
  type = string
}

variable "image" {
  type = string
}

variable "priority" {
  type    = number
  default = 29000
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
    load_balancer = object({
      arn      = string
      dns_name = string
    })
  })
}

variable "env" {
  type    = map(string)
  default = {}
}

variable "secrets" {
  type = object({
    credentials = object({
      arn = string
    })
  })
}

locals {
  tld = regex("[a-z-_]*.[a-z-_]*$", var.domain)
}

resource "aws_lb_target_group" "this" {
  name        = trim(substr("${var.app_env}-${var.app_name}", 0, 30), "-")
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.network_configuration.vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 5
    matcher             = "200,302"
  }

  tags = {
    Environment = var.app_env
  }
}

data "aws_lb_listener" "http" {
  load_balancer_arn = var.network_configuration.load_balancer.arn
  port              = 80
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = data.aws_lb_listener.http.arn
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = [var.domain]
    }
  }

  tags = {
    # Name        = var.app_dns
    Environment = var.app_env
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = "${var.app_env}-${var.app_name}"

  tags = {
    Environment = var.app_env
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

data "aws_service_discovery_http_namespace" "env" {
  name = var.app_env
}

resource "aws_ecs_service" "this" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.service.arn

  launch_type   = "FARGATE"
  desired_count = 1

  network_configuration {
    subnets         = var.network_configuration.subnets
    security_groups = var.network_configuration.security_groups
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.app_env
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.app_name
    container_port   = 3000
  }

  tags = {
    Environment = var.app_env
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = "${var.app_env}-${var.app_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 2048
  memory = 4096

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = var.role.arn
  task_role_arn      = var.role.arn

  container_definitions = jsonencode([{
    name      = var.app_name
    image     = var.image
    cpu       = 512
    memory    = 1024
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
      protocol      = "tcp"
    }]
    environment = [for name, value in merge({
      "PORT" : "3000",
      "NODE_ENV" : "production",
      }, var.env) : {
      name  = name
      value = value
    }]
    secrets = [
      {
        name      = "CLICKHOUSE_PASSWORD"
        valueFrom = "${var.secrets.credentials.arn}:CLICKHOUSE_PASSWORD::"
      },
      {
        name      = "COOKIE_SECRET"
        valueFrom = "${var.secrets.credentials.arn}:COOKIE_SECRET::"
      },
      {
        name      = "LICENSE_KEY"
        valueFrom = "${var.secrets.credentials.arn}:LICENSE_KEY::"
      },
      {
        name      = "DATABASE_URL"
        valueFrom = "${var.secrets.credentials.arn}:DATABASE_URL::"
      },
      {
        name      = "DATABASE_URL_ENTITY"
        valueFrom = "${var.secrets.credentials.arn}:DATABASE_URL_ENTITY::"
      }
    ]

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

output "lb_target_group" {
  value = aws_lb_target_group.this
}
