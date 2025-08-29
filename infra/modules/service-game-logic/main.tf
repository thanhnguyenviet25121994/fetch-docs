terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

variable "app_name" {
  type    = string
  default = "service-game-logic"
}

variable "app_env" {
  type = string
}

variable "image" {
  type    = string
  default = ""
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

variable "env" {
  type    = map(string)
  default = {}
}

variable "instance_count" {
  type = object({
    min = number,
    max = number
  })
  default = {
    min = 1
    max = 32
  }
}

variable "public_routes" {
  type = object({
    enabled     = bool,
    root_domain = string,
    load_balancer_listener = object({
      arn               = string
      load_balancer_arn = string
    })
  })
}



resource "aws_cloudwatch_log_group" "this" {
  name = "${var.app_env}-${var.app_name}"

  tags = {
    Environment = var.app_env
  }
}
resource "aws_cloudwatch_log_group" "services" {
  for_each = var.services
  name     = "${var.app_env}-${each.key}"

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

# module "container_definitions" {
#   source = "../task-definition"

#   name = var.app_name

#   essential = true

#   cpu = 0
#   # memory = 0
#   image = var.image
#   port_mappings = [{
#     name          = var.app_name
#     appProtocol   = "http"
#     containerPort = 9200
#   }]

#   environment = [for name, value in merge({
#     "API_PORT" : "9200",
#     "API_HOST" : "0.0.0.0",
#     "APP_ENV" : var.app_env,
#     "NODE_ENV" : "production",
#     "LOG_LEVEL" : "error"
#     }, var.env) : {
#     name  = name
#     value = value
#   }]
#   memory_reservation          = 100
#   create_cloudwatch_log_group = false
#   enable_cloudwatch_logging   = true
#   cloudwatch_log_group_name   = aws_cloudwatch_log_group.this.name

#   # log_configuration = {
#   #   logDriver = "awslogs"
#   #   options = {
#   #     awslogs-group  = aws_cloudwatch_log_group.this.name
#   #     awslogs-region = var.network_configuration.region
#   #   }
#   # }
#   health_check = {
#     command  = ["CMD-SHELL", "exit 0"]
#     interval = 30
#     retries  = 3
#     timeout  = 5
#   }


#   # Example image used requires access to write to root filesystem
#   readonly_root_filesystem = false

# }

# module "ecs_service" {
#   source  = "terraform-aws-modules/ecs/aws//modules/service"
#   version = "v5.11.2"

#   name = var.app_name

#   family = "${var.app_env}-${var.app_name}"

#   container_definition_defaults = {
#     cloudwatch_log_group_retention_in_days = 7
#     cloudwatch_log_group_name              = aws_cloudwatch_log_group.this.name
#     create_cloudwatch_log_group            = false
#     enable_cloudwatch_logging              = true
#     log_configuration = {
#       logDriver = "awslogs"
#       options = {
#         awslogs-group         = aws_cloudwatch_log_group.this.name
#         awslogs-region        = var.network_configuration.region
#         awslogs-stream-prefix = "ecs"
#         mode                  = "non-blocking"
#         max-buffer-size       = "1m"
#       }
#     }
#   }

#   container_definitions = {
#     (var.app_name) = module.container_definitions.container_definition
#   }
#   cluster_arn      = aws_ecs_cluster.this.id
#   launch_type      = "FARGATE"
#   platform_version = "LATEST"

#   create_task_exec_iam_role = false
#   # create_task_definition = false
#   cpu                                = var.task_size_cpu
#   memory                             = var.task_size_memory
#   enable_execute_command             = true
#   desired_count                      = var.instance_count.min
#   health_check_grace_period_seconds  = 0
#   create_tasks_iam_role              = false
#   task_exec_iam_role_arn             = var.role.arn
#   tasks_iam_role_arn                 = var.role.arn
#   iam_role_arn                       = var.role.arn
#   subnet_ids                         = var.network_configuration.subnets
#   create_security_group              = false
#   security_group_ids                 = var.network_configuration.security_groups
#   network_mode                       = "awsvpc"
#   assign_public_ip                   = false
#   ignore_task_definition_changes     = false
#   deployment_minimum_healthy_percent = 100
#   deployment_maximum_percent         = 200
#   deployment_controller = {
#     type = "ECS"
#   }
#   runtime_platform = {
#     operating_system_family = "LINUX"
#     cpu_architecture        = "ARM64"
#   }

#   service_connect_configuration = {
#     namespace = var.app_env

#     service = {
#       client_alias = {
#         port     = 80
#         dns_name = var.app_name
#       }
#       port_name      = var.app_name
#       discovery_name = var.app_name
#     }
#   }

#   load_balancer = {
#     for idx, lb in var.network_configuration.load_balancer_target_groups : idx => {
#       target_group_arn = lb.arn
#       container_name   = var.app_name
#       container_port   = lb.port
#     }
#   }

#   enable_autoscaling       = true
#   autoscaling_min_capacity = var.instance_count.min
#   autoscaling_max_capacity = var.instance_count.max
#   autoscaling_policies = {
#     cpu = {
#       policy_type = "TargetTrackingScaling"

#       target_tracking_scaling_policy_configuration = {
#         predefined_metric_specification = {
#           predefined_metric_type = "ECSServiceAverageCPUUtilization"
#         }
#         target_value = 80
#       }
#     }
#     memory = {
#       policy_type = "TargetTrackingScaling"

#       target_tracking_scaling_policy_configuration = {
#         predefined_metric_specification = {
#           predefined_metric_type = "ECSServiceAverageMemoryUtilization"
#           target_value           = 80
#         }
#         target_value = 80
#       }
#     }
#   }

#   depends_on = [module.container_definitions]

# }


### OTHERS SERVICES IN GAME-LOGIC-SERVICE CLUSTER

variable "services" {
  description = "Map of services"
  type = map(object({
    image = string
    env = list(object({
      name  = string
      value = string
    }))
  }))
}



# Let's always have a target group, to utilize the LB's health-check
# functionality. It doesn't matter if the service is not going to be publicly
# available.
resource "aws_lb_target_group" "services" {
  for_each    = tomap(var.services)
  name        = trim(substr("${each.key}", 0, 32), "-")
  port        = 8200
  protocol    = "HTTP"
  vpc_id      = var.network_configuration.vpc.id
  target_type = "ip"

  health_check {
    path                = "/health-check"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener_rule" "services" {
  for_each     = tomap(var.services)
  listener_arn = var.public_routes.load_balancer_listener.arn
  priority     = 410 + index(keys(var.services), each.key) + 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services[each.key].arn
  }

  condition {
    host_header {
      values = ["${each.key}.*"]
    }
  }

  tags = {
    Name = "${each.key}.${var.public_routes.root_domain}"
  }
}


locals {
  tld = regex("[a-z-_]*.[a-z-_]*$", var.public_routes.root_domain)
}

data "cloudflare_zone" "root" {
  name = local.tld
}

data "aws_lb" "target" {
  arn = var.public_routes.load_balancer_listener.load_balancer_arn
}

resource "cloudflare_record" "services" {
  for_each = var.public_routes.enabled ? var.services : {}
  zone_id  = data.cloudflare_zone.root.zone_id
  name     = "${each.key}.${var.public_routes.root_domain}"
  content  = data.aws_lb.target.dns_name
  type     = "CNAME"
  proxied  = true
}

module "container_definitions_services" {
  for_each = tomap(var.services)
  source   = "../task-definition"

  name  = each.key
  image = each.value.image

  essential = true

  cpu = 0
  # memory = 0
  port_mappings = [{
    name          = each.key
    appProtocol   = "http"
    containerPort = 8200
  }]

  environment = concat([{
    name  = "API_PORT"
    value = "8200"
    }, {
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
  }], each.value.env)
  memory_reservation          = 100
  create_cloudwatch_log_group = false
  enable_cloudwatch_logging   = false
  cloudwatch_log_group_name   = aws_cloudwatch_log_group.this.name
  # log_configuration = {
  #   logDriver = "awslogs"
  #   options = {
  #     awslogs-group  = aws_cloudwatch_log_group.this.name
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

module "ecs_service_services" {
  for_each = tomap(var.services)
  source   = "terraform-aws-modules/ecs/aws//modules/service"
  version  = "v5.11.2"

  name = each.key

  family = "${var.app_env}-${each.key}"
  container_definition_defaults = {
    cloudwatch_log_group_retention_in_days = 7
    cloudwatch_log_group_name              = aws_cloudwatch_log_group.services["${each.key}"].name
    create_cloudwatch_log_group            = false
    enable_cloudwatch_logging              = true
    log_configuration = {
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
    (each.key) = module.container_definitions_services["${each.key}"].container_definition
  }
  cluster_arn      = aws_ecs_cluster.this.id
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  create_task_exec_iam_role = false
  # create_task_definition = false
  cpu                                = var.task_size_cpu
  memory                             = var.task_size_memory
  enable_execute_command             = true
  desired_count                      = var.instance_count.min
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
        dns_name = each.key
      }
      port_name      = each.key
      discovery_name = each.key
    }
  }

  load_balancer = {
    service = {
      target_group_arn = aws_lb_target_group.services[each.key].arn
      container_name   = each.key
      container_port   = 8200
    }

  }

  enable_autoscaling       = true
  autoscaling_min_capacity = var.instance_count.min
  autoscaling_max_capacity = var.instance_count.max
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

  depends_on = [module.container_definitions_services]

}
