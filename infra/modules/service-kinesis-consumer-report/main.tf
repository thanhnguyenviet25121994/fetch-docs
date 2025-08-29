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
  default = "service-kinesis-consumer-report"
}

variable "app_env" {
  type = string
}

variable "image" {
  type = string
}

variable "task_size_cpu" {
  type    = number
  default = 1024
}

variable "task_size_memory" {
  type    = number
  default = 2048
}

variable "instance_count_min" {
  type    = number
  default = 1
}

variable "instance_count_max" {
  type    = number
  default = 256
}

variable "env" {
  type    = map(string)
  default = {}
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
    security_groups = list(string)
    # load_balancer_target_groups = list(object({
    #   arn  = string,
    #   port = number
    # }))
  })
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

module "container_definition" {
  source = "../task-definition"

  name = var.app_name

  essential = true

  cpu = 0
  # memory = 2048
  image                       = var.image
  create_cloudwatch_log_group = false
  enable_cloudwatch_logging   = false

  environment = [for name, value in merge({
    "SERVER_PORT" : "8080",
    "LOG_LEVEL" : "debug",
    }, var.env) : {
    name  = name
    value = value
  }]

  secrets = [
  ]
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group   = aws_cloudwatch_log_group.this.name
      awslogs-region  = var.network_configuration.region
      mode            = "non-blocking"
      max-buffer-size = "1m"
    }
  }

  memory_reservation = 100

  # For task definitions that use the awsvpc network mode, only specify the containerPort.
  # The hostPort can be left blank or it must be the same value as the containerPort
  port_mappings = [
    {
      name          = var.app_name
      containerPort = 8080
      hostPort      = 8080
      protocol      = "tcp"
      appProtocol   = "http"
    }
  ]


  # Example image used requires access to write to root filesystem
  readonly_root_filesystem = false

}

module "ecs_svc" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "v5.11.2"

  name = var.app_name

  family = "${var.app_env}-${var.app_name}"

  container_definition_defaults = {
    cloudwatch_log_group_retention_in_days = 7
    cloudwatch_log_group_name              = aws_cloudwatch_log_group.this.name
    create_cloudwatch_log_group            = false
    enable_cloudwatch_logging              = true
    log_configuration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this.name
        awslogs-region        = var.network_configuration.region
        awslogs-stream-prefix = "ecs"
        mode                  = "non-blocking"
        max-buffer-size       = "1m"
      }
    }
  }
  container_definitions = {
    (var.app_name) = module.container_definition.container_definition
  }
  cluster_arn      = aws_ecs_cluster.this.id
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  create_task_exec_iam_role = false
  # create_task_definition = false
  cpu                                = var.task_size_cpu
  memory                             = var.task_size_memory
  enable_execute_command             = true
  desired_count                      = var.instance_count_min
  health_check_grace_period_seconds  = 30
  create_tasks_iam_role              = false
  task_exec_iam_role_arn             = var.role.arn
  tasks_iam_role_arn                 = var.role.arn
  iam_role_arn                       = var.role.arn
  subnet_ids                         = var.network_configuration.subnets
  create_security_group              = false
  security_group_ids                 = var.network_configuration.security_groups
  network_mode                       = "awsvpc"
  assign_public_ip                   = false
  ignore_task_definition_changes     = false
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  deployment_controller = {
    type = "ECS"
  }
  runtime_platform = {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  service_connect_configuration = {
    namespace = var.app_env

    service = {
      client_alias = {
        port     = 80
        dns_name = var.app_name
      }
      port_name      = var.app_name
      discovery_name = var.app_name
    }
  }
  load_balancer = {
    # for idx, lb in var.network_configuration.load_balancer_target_groups : idx => {
    #   target_group_arn = lb.arn
    #   container_name   = var.app_name
    #   container_port   = lb.port
    # }
  }

  enable_autoscaling = false

  depends_on = [module.container_definition]
}
