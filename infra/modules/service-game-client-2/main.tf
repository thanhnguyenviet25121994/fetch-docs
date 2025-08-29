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
  default = 3
}

variable "instance_count_max" {
  type    = number
  default = 256
}

variable "filter_pattern" {
  type = string
}

variable "retention_in_days" {
  type    = number
  default = 30
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

variable "services" {
  description = "Map of services"
  type = map(object({
    env = map(string)
    lb  = map(string)
  }))
}

variable "deployment_maximum_percent" {
  type    = number
  default = 200
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.app_env}-${var.app_name}"
  retention_in_days = var.retention_in_days

  tags = {
    Environment = "${var.app_env}"
  }
}

resource "aws_cloudwatch_log_metric_filter" "error_filter" {
  name           = "${var.app_env}-${var.app_name}-ErrorFilter"
  pattern        = "ERROR -\"o.s.w.reactive.socket.WebSocketHandler\" -\"Session mismatch\" -\"UNKNOWN\" -\"Missing bet setting\" -\"PlayServiceV2\" \"mahjong-fortune\" -\"bikini-babes\" -\"mermaid\" -\"run-pug-run\" -\"mochi-mochi\" -\"pandora\" -\"rave-on\" -\"samba-fiesta\" -\"sanguo\" -\"stallion-gold\" -\"sexy-christmas\""
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

# resource "aws_dynamodb_table" "bet_results" {
#   name     = "${var.app_env}_bet_results"
#   hash_key = "BetId"

#   billing_mode = "PAY_PER_REQUEST"

#   attribute {
#     name = "BetId"
#     type = "S"
#   }

#   ttl {
#     attribute_name = "ttl"
#     enabled        = true
#   }

#   tags = {
#     Name        = "${var.app_env}_bet_results"
#     Environment = var.app_env
#   }
# }

resource "aws_elasticache_subnet_group" "cache" {
  name       = "${var.app_env}-${var.app_name}"
  subnet_ids = var.network_configuration.subnets
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
    # "OPENSEARCH_ENABLED" : "false",
    # "OPENSEARCH_URIS" : "https://${var.opensearch.endpoint}:443",
    "PLAYER_ONLINE_EXPIRY" : "PT2H",
    "SPRING.CODEC.MAX-IN-MEMORY-SIZE" : "20MB",
    # "JAVA_OPTS" : "-Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dspring.r2dbc.write.pool.max-size=8 -Dspring.r2dbc.write.pool.initial-size=4 -Dspring.r2dbc.read.pool.max-size=10 -Dspring.r2dbc.read.pool.initial-size=5 -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dlogging.level.com.revenge.game.features.play=INFO -Dlogging.level.com.revenge.game.features.play=OFF",
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
  cluster_arn      = aws_ecs_cluster.this.id
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
  deployment_maximum_percent         = var.deployment_maximum_percent
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

  deployment_circuit_breaker = {
    enable   = true
    rollback = true
  }

  # alarms = {
  #   alarm_names = var.alarm_names
  #   enable = true
  #   rollback = true
  # }

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
        target_value = 70
      }
    }
    memory = {
      policy_type = "TargetTrackingScaling"

      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageMemoryUtilization"
          target_value           = 70
        }
        target_value = 70
      }
    }
  }

  depends_on = [module.container_definition_service_game_client]

}


##########
## services
##########
resource "aws_cloudwatch_log_group" "services" {
  for_each = var.services
  name     = "${var.app_env}-${each.key}"

  tags = {
    Environment = var.app_env
  }
}
module "container_definition_services" {
  for_each = var.services
  source   = "../task-definition"

  name = each.key

  essential = true

  cpu = 0
  # memory = 0
  image = var.image
  port_mappings = [{
    name          = each.key
    appProtocol   = "http"
    containerPort = each.key == "service-game-client-dashboard" || each.key == "srv-game-client-dashboard" ? 9301 : 9300
  }]

  environment = [for name, value in merge({
    "SERVER_PORT" : "9300",
    # "OPENSEARCH_ENABLED" : "false",
    # "OPENSEARCH_URIS" : "https://${var.opensearch.endpoint}:443",
    "SPRING.CODEC.MAX-IN-MEMORY-SIZE" : "20MB"
    "PLAYER_ONLINE_EXPIRY" : "PT2H",
    }, each.value.env) : {
    name  = name
    value = value
  }]
  memory_reservation          = 100
  create_cloudwatch_log_group = false
  enable_cloudwatch_logging   = false
  # log_configuration = {
  #   logDriver = "awslogs"
  #   options = {
  #     awslogs-group  = aws_cloudwatch_log_group.services["${each.key}"].name
  #     awslogs-region = var.network_configuration.region
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

module "ecs_svc_services" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "v5.11.2"

  for_each = var.services

  name = each.key

  family = "${var.app_env}-${each.key}"

  container_definition_defaults = {
    cloudwatch_log_group_retention_in_days = 7
    cloudwatch_log_group_name              = aws_cloudwatch_log_group.services["${each.key}"].name
    create_cloudwatch_log_group            = false
    enable_cloudwatch_logging              = true
    log_configuration = var.app_env == "dev" ? {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.services["${each.key}"].name
        awslogs-region        = var.network_configuration.region
        awslogs-stream-prefix = "ecs"
      }
      } : {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.services["${each.key}"].name
        awslogs-region        = var.network_configuration.region
        awslogs-stream-prefix = "ecs"
        mode                  = "non-blocking"
        max-buffer-size       = "1m"
      }
    }
  }

  container_definitions = {
    (each.key) = module.container_definition_services["${each.key}"].container_definition
  }
  cluster_arn      = aws_ecs_cluster.this.id
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  create_task_exec_iam_role = false
  # create_task_definition = false
  cpu                                = var.task_size_cpu
  memory                             = var.task_size_memory
  enable_execute_command             = true
  desired_count                      = (each.key == "srv-game-client-dashboard" || each.key == "srv-game-client-worker" || each.key == "service-game-client-dashboard" || each.key == "service-game-client-worker") ? 1 : 2
  health_check_grace_period_seconds  = each.key == "srv-game-client-worker" || each.key == "service-game-client-worker" ? 0 : 30
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
        dns_name = each.key
      }
      port_name      = each.key
      discovery_name = each.key
    }
  }

  load_balancer = each.key == "service-game-client-worker" || each.key == "srv-game-client-worker" ? {} : {
    service = {
      target_group_arn = each.value.lb.arn
      container_name   = each.key
      container_port   = each.value.lb.port
    }
  }

  enable_autoscaling       = each.key == "service-game-client-dashboard" || each.key == "srv-game-client-worker" ? false : true
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


}
