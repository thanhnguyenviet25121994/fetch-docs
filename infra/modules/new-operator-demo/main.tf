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

variable "task_size_cpu" {
  type    = number
  default = 512
}

variable "task_size_memory" {
  type    = number
  default = 1024
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
  default = 2
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

module "container_definitions" {
  source = "../task-definition"

  name = var.app_name

  essential = true

  cpu = 0
  # memory = 0
  image = var.image
  port_mappings = [{
    name          = "${var.app_name}"
    containerPort = 9400
    appProtocol   = "http"
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
  source = "../ecs-service"
  # version = "v5.7.4"

  name = var.app_name

  family = "${var.app_env}-${var.app_name}"

  container_definition_defaults = {
    cloudwatch_log_group_retention_in_days = 7
    cloudwatch_log_group_name              = aws_cloudwatch_log_group.this.name
    create_cloudwatch_log_group            = false
    enable_cloudwatch_logging              = true
    log_configuration = var.app_env == "dev" ? {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this.name
        awslogs-region        = var.network_configuration.region
        awslogs-stream-prefix = "ecs"
      }
      } : {
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
  desired_count                      = 1
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
    "config1" = {
      namespace = var.app_env
      services = [
        {
          client_alias = [
            {
              port     = 80
              dns_name = "${var.app_name}.dev"
            }
          ]
          port_name      = "${var.app_name}"
          discovery_name = "${var.app_name}"
        }
      ]
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

# resource "aws_ecs_service" "this" {
#   name            = var.app_name
#   cluster         = aws_ecs_cluster.this.id
#   task_definition = aws_ecs_task_definition.service.arn

#   launch_type                       = "FARGATE"
#   desired_count                     = 2
#   health_check_grace_period_seconds = 30

#   network_configuration {
#     subnets          = var.network_configuration.subnets
#     security_groups  = var.network_configuration.security_groups
#     assign_public_ip = false
#   }

#   service_connect_configuration {
#     enabled   = true
#     namespace = var.app_env

#     service {
#       client_alias {
#         port = 80
#       }
#       port_name = var.app_name
#     }
#   }

#   dynamic "load_balancer" {
#     for_each = var.network_configuration.load_balancer_target_groups
#     content {
#       target_group_arn = load_balancer.value.arn
#       container_port   = load_balancer.value.port
#       container_name   = var.app_name
#     }
#   }

#   tags = {
#     Environment = var.app_env
#   }

#   lifecycle {
#     ignore_changes = [
#       desired_count
#     ]
#   }
# }

# resource "aws_ecs_task_definition" "service" {
#   family                   = "${var.app_env}-${var.app_name}"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]

#   cpu    = 512
#   memory = 1024

#   runtime_platform {
#     operating_system_family = "LINUX"
#     cpu_architecture        = "ARM64"
#   }

#   execution_role_arn = var.role.arn

#   container_definitions = jsonencode([{
#     name      = var.app_name
#     image     = var.image
#     essential = true
#     portMappings = [{
#       containerPort = 9400
#       appProtocol   = "http"
#       name          = var.app_name
#     }]
#     environment = concat([{
#       name  = "SERVER_PORT"
#       value = "9400"
#       }, {
#       name  = "SPRING_R2DBC_URL"
#       value = "r2dbc:postgresql://${var.db.endpoint}:5432/${var.db.name}"
#       }], [for name, value in var.env : {
#       name  = name
#       value = value
#     }])
#     secrets = [{
#       name      = "SPRING_R2DBC_USERNAME",
#       valueFrom = "${var.db.credentials.arn}:username::"
#       }, {
#       name      = "SPRING_R2DBC_PASSWORD",
#       valueFrom = "${var.db.credentials.arn}:password::"
#     }]
#     logConfiguration = {
#       logDriver = "awslogs"
#       options = {
#         "awslogs-group"         = aws_cloudwatch_log_group.this.name
#         "awslogs-region"        = var.network_configuration.region
#         "awslogs-stream-prefix" = "ecs"
#         "mode"                  = "non-blocking"
#         "max-buffer-size"       = "1m"
#       }
#     }
#     healthcheck = {
#       command  = ["CMD-SHELL", "exit 0"]
#       interval = 30
#       retries  = 3
#       timeout  = 5
#     }
#     mountPoints    = []
#     systemControls = []
#     volumesFrom    = []
#   }])

#   tags = {
#     Environment = var.app_env
#   }
# }

# resource "aws_appautoscaling_policy" "this_memory" {
#   name               = "${aws_ecs_cluster.this.name}-${aws_ecs_service.this.name}-memory"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.this.resource_id
#   scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.this.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageMemoryUtilization"
#     }

#     target_value = 80

#     scale_in_cooldown  = 300
#     scale_out_cooldown = 60
#   }
# }

# resource "aws_appautoscaling_policy" "this_cpu" {
#   name               = "${aws_ecs_cluster.this.name}-${aws_ecs_service.this.name}-cpu"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.this.resource_id
#   scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.this.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageCPUUtilization"
#     }

#     target_value = 80

#     scale_in_cooldown  = 300
#     scale_out_cooldown = 60
#   }
# }

# resource "aws_appautoscaling_target" "this" {
#   max_capacity       = var.instance_count_max
#   min_capacity       = var.instance_count_min
#   resource_id        = "service/${aws_ecs_cluster.this.name}/${module.ecs_service.name}"
#   scalable_dimension = "ecs:service:DesiredCount"
#   service_namespace  = "ecs"
# }
