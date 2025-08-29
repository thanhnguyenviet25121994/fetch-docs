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
  default = "fortune-dragon-logic"
}

variable "app_env" {
  type = string
}

variable "image" {
  type = string
}

variable "role" {
  type = object({
    arn = string
  })
}

variable "task_size_memory" {
  type    = string
  default = 512
}

variable "task_size_cpu" {
  type    = string
  default = 256
}

variable "network_configuration" {
  type = object({
    vpc = object({
      id = string
    })
    region          = string
    subnets         = list(string),
    security_groups = list(string),
    load_balancer_target_groups = list(object({
      arn  = string
      port = number
    }))
  })
}

variable "instance_count_min" {
  type    = number
  default = 2
}

variable "instance_count_max" {
  type    = number
  default = 512
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

module "container_definitions" {
  source = "../task-definition"

  name = var.app_name

  essential = true

  cpu = 0
  # memory = 0
  image = var.image
  port_mappings = [{
    name          = var.app_name
    appProtocol   = "http"
    containerPort = 8200
  }]

  environment = [{
    name  = "PORT"
    value = "8200"
    }, {
    name  = "API_HOST"
    value = "0.0.0.0"
    }, {
    name  = "APP_ENV"
    value = var.app_env
    }, {
    name  = "NODE_ENV"
    value = "production"
    }, {
    name  = "LOG_LEVEL"
    value = "error"
  }]
  memory_reservation          = 100
  create_cloudwatch_log_group = false
  enable_cloudwatch_logging   = false
  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-group   = aws_cloudwatch_log_group.this.name
      awslogs-region  = var.network_configuration.region
      mode            = "non-blocking"
      max-buffer-size = "1m"
    }
  }
  health_check = {
    command  = ["CMD-SHELL", "exit 0"]
    interval = 30
    retries  = 3
    timeout  = 5
  }


  # Example image used requires access to write to root filesystem
  readonly_root_filesystem = false

}

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "v5.7.4"

  name = var.app_name

  family = "${var.app_env}-${var.app_name}"

  container_definitions = {
    (var.app_name) = module.container_definitions.container_definition
  }
  cluster_arn      = aws_ecs_cluster.this.id
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  create_task_exec_iam_role = false
  # create_task_definition = false
  cpu                                = var.task_size_cpu
  memory                             = var.task_size_memory
  enable_execute_command             = true
  desired_count                      = 2
  health_check_grace_period_seconds  = 0
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
    for idx, lb in var.network_configuration.load_balancer_target_groups : idx => {
      target_group_arn = lb.arn
      container_name   = var.app_name
      container_port   = lb.port
    }
  }

  enable_autoscaling       = true
  autoscaling_min_capacity = var.instance_count_min
  autoscaling_max_capacity = var.instance_count_max
  autoscaling_policies = {
    cpu = {
      policy_type = "TargetTrackingScaling"

      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
        target_value = 80
      }
    }
    memory = {
      policy_type = "TargetTrackingScaling"

      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageMemoryUtilization"
          target_value           = 80
        }
        target_value = 80
      }
    }
  }

  depends_on = [module.container_definitions]

}
