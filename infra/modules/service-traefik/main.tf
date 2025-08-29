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
  default = "service-static-router"
}
variable "desired_count" {
  type    = number
  default = 1
}
variable "task_cpu" {
  type    = number
  default = 256

}
variable "task_mem" {
  type    = number
  default = 512
}

variable "app_env" {
  type = string
}

variable "config_url" {
  type = string
}

variable "role" {
  type = object({
    arn = string
  })
}

variable "network_configuration" {
  type = object({
    region          = string
    subnets         = list(string),
    security_groups = list(string),
    load_balancer_target_groups = list(object({
      arn  = string,
      port = number
    }))
  })
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

resource "aws_ecs_service" "this" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.service.arn

  launch_type   = "FARGATE"
  desired_count = var.desired_count

  network_configuration {
    subnets         = var.network_configuration.subnets
    security_groups = var.network_configuration.security_groups
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.app_env
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
}

resource "aws_ecs_task_definition" "service" {
  family                   = "${var.app_env}-${var.app_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = var.task_cpu
  memory = var.task_mem

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  execution_role_arn = var.role.arn

  container_definitions = jsonencode([{
    name      = var.app_name
    image     = "traefik:v2.10"
    essential = true
    portMappings = [{
      name          = "${var.app_name}-http"
      containerPort = 80
      appProtocol   = "http"
    }]
    command = [
      "traefik",
      "--providers.http.endpoint=http://${var.config_url}",
      "--ping=true",
      "--ping.entryPoint=http"
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
