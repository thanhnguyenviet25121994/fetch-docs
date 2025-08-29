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
  default = "service-game-client"
}

variable "ecs_cluster_arn" {
  type = string
}

variable "app_env" {
  type = string
}
variable "desired_count" {
  type    = number
  default = 2
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
  default = 2
}

variable "instance_count_max" {
  type    = number
  default = 256
}

variable "filter_pattern" {
  type = string
}

# variable "opensearch" {
#   type = object({
#     endpoint = string
#     credentials = object({
#       arn = string
#     })
#   })
# }

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


resource "aws_cloudwatch_log_group" "this" {
  name = "${var.app_env}-${var.app_name}"

  tags = {
    Environment = "${var.app_env}"
  }
}

resource "aws_cloudwatch_log_group" "otel_sidecar" {
  name = "${var.app_env}-${var.app_name}-otel-sidecar"

  tags = {
    Environment = "${var.app_env}"
  }
}

resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "${var.app_env}-${var.app_name}-ErrorFilter"
  pattern        = "ERROR -\"o.s.w.reactive.socket.WebSocketHandler\" -\"Session mismatch\" -\"UNKNOWN\" -\"Missing bet setting\""
  log_group_name = aws_cloudwatch_log_group.this.name

  metric_transformation {
    name          = "ErrorCount"
    namespace     = "LogMetrics"
    value         = "1"
    default_value = 0
  }
}

resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name          = "${var.app_env}-${var.app_name}-ErrorAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ErrorCount"
  namespace           = "LogMetrics"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "Alarm when there are errors in logs"
  alarm_actions       = [aws_sns_topic.error_notification_topic.arn]

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.this.name
  }
}

####Send to telegram
resource "aws_sns_topic" "error_notification_topic" {
  name = "${var.app_env}-${var.app_name}-ErrorNotificationTopic"
}

# resource "aws_sns_topic_subscription" "telegram_subscription" {
#   topic_arn = aws_sns_topic.error_notification_topic.arn
#   protocol  = "https"
#   endpoint  = "https://api.telegram.org/bot7041240046:AAFAcTCTO6a8LzwjlNvdLePVdNRZIPtJd3w/sendMessage?chat_id=538543235&text=Error occurred in log group: ${aws_cloudwatch_log_metric_filter.error_filter.log_group_name}"
# }

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




module "container_definition_service_game_client" {
  source = "../task-definition"

  name = var.app_name

  essential = true

  cpu = 0
  # memory = 0
  image = var.image
  port_mappings = [{
    name          = var.app_name
    appProtocol   = "http"
    containerPort = 9300
  }]

  environment = [for name, value in merge({
    "SERVER_PORT" : "9300",
    "PLAYER_ONLINE_EXPIRY" : "PT2H",
    "SPRING.CODEC.MAX-IN-MEMORY-SIZE" : "20MB"
    }, var.env) : {
    name  = name
    value = value
  }]
  memory_reservation          = 100
  create_cloudwatch_log_group = false
  enable_cloudwatch_logging   = false
  # log_configuration = {
  #   logDriver = "awslogs"
  #   options = {
  #     awslogs-group   = aws_cloudwatch_log_group.this.name
  #     awslogs-region  = var.network_configuration.region
  #     mode            = "non-blocking"
  #     max-buffer-size = "1m"
  #   }
  # }
  health_check = {
    command  = ["CMD-SHELL", "exit 0"]
    interval = 30
    retries  = 3
    timeout  = 5
  }


  # Example image used requires access to write to root filesystem
  readonly_root_filesystem = false

}

module "ecs_svc_service_game_client" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "v5.11.2"

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
    (var.app_name) = module.container_definition_service_game_client.container_definition
  }
  cluster_arn      = var.ecs_cluster_arn
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  create_task_exec_iam_role = false
  # create_task_definition = false
  cpu                                = var.task_size_cpu
  memory                             = var.task_size_memory
  enable_execute_command             = true
  desired_count                      = var.desired_count
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

  depends_on = [module.container_definition_service_game_client]

}
