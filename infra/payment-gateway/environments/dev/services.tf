
locals {


  pg_services = {
    pg-server = {
      image                              = "${module.ecrs.repository_url_map["revengegames/pg-server"]}:v1.0.185.1"
      mount_points                       = []
      healthcheck_path                   = "/actuator/health"
      alb_disable                        = false
      volume                             = []
      health_check_grace_period_seconds  = 60
      deployment_minimum_healthy_percent = 100
      deployment_maximum_percent         = 200
      cpu                                = 1024
      mem                                = 2048
      desired_count                      = 1
      security_group_ids                 = [module.service_sg.security_group_id]
      environment = [
        {
          name  = "JAVA_OPTS",
          value = "-Djava.net.preferIPv4Stack=true"
        }
      ]
      secrets = [
        {
          name      = "SPRING_R2DBC_URL"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_server_env.arn}:SPRING_R2DBC_URL::"
        },
        {
          name      = "SPRING_R2DBC_USERNAME"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_server_env.arn}:SPRING_R2DBC_USERNAME::"
        },
        {
          name      = "SERVER_PORT"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_server_env.arn}:SERVER_PORT::"
        },
        {
          name      = "SPRING_R2DBC_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_server_env.arn}:SPRING_R2DBC_PASSWORD::"
        },
        {
          name      = "SPRING_FLYWAY_URL"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_server_env.arn}:SPRING_FLYWAY_URL::"
        },
        {
          name      = "SPRING_FLYWAY_USER"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_server_env.arn}:SPRING_FLYWAY_USER::"
        },
        {
          name      = "SPRING_FLYWAY_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_server_env.arn}:SPRING_FLYWAY_PASSWORD::"
        },
        {
          name      = "AWS_S3_ENDPOINTURL"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_server_env.arn}:AWS_S3_ENDPOINTURL::"
        },
        {
          name      = "AWS_S3_BUCKETNAME"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_server_env.arn}:AWS_S3_BUCKETNAME::"
        }
      ]
      enable_autoscaling       = true
      autoscaling_min_capacity = 1
      autoscaling_max_capacity = 256
      command                  = []
      health_check             = {}
      port_mappings = [
        {
          name          = "pg-server"
          appProtocol   = "http"
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      conditions = [{
        host_header = {
          values = ["payment.dev.revenge-games.com"]
        },
        path_pattern = {
          values = ["/*"]
        }
      }]
    },
    pg-demo-merchant-server = {
      image                              = "${module.ecrs.repository_url_map["revengegames/pg-demo-merchant-server"]}:v1.0.6.1"
      mount_points                       = []
      healthcheck_path                   = "/actuator/health"
      alb_disable                        = false
      volume                             = []
      health_check_grace_period_seconds  = 60
      deployment_minimum_healthy_percent = 100
      deployment_maximum_percent         = 200
      cpu                                = 1024
      mem                                = 2048
      desired_count                      = 1
      security_group_ids                 = [module.service_sg.security_group_id]
      environment = [
        {
          name  = "JAVA_OPTS",
          value = "-Djava.net.preferIPv4Stack=true"
        },
        {
          name  = "PG_CLIENT_PAYMENTCHECKOUT_URL",
          value = "https://payment.dev.revenge-games.com/payment-checkout"
        }
      ]
      secrets = [
        {
          name      = "SPRING_R2DBC_URL"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_demo_merchant_server_env.arn}:SPRING_R2DBC_URL::"
        },
        {
          name      = "SPRING_R2DBC_USERNAME"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_demo_merchant_server_env.arn}:SPRING_R2DBC_USERNAME::"
        },
        {
          name      = "SERVER_PORT"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_demo_merchant_server_env.arn}:SERVER_PORT::"
        },
        {
          name      = "SPRING_R2DBC_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_demo_merchant_server_env.arn}:SPRING_R2DBC_PASSWORD::"
        },
        {
          name      = "RG_BASEURL"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_demo_merchant_server_env.arn}:RG_BASEURL::"
        },
        {
          name      = "RG_CODE"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_demo_merchant_server_env.arn}:RG_CODE::"
        },
        {
          name      = "RG_SECRET"
          valueFrom = "${data.aws_secretsmanager_secret.dev_pg_demo_merchant_server_env.arn}:RG_SECRET::"
        }
      ]
      enable_autoscaling       = true
      autoscaling_min_capacity = 1
      autoscaling_max_capacity = 256
      command                  = []
      health_check             = {}
      port_mappings = [
        {
          name          = "pg-demo-merchant-server"
          appProtocol   = "http"
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      conditions = [{
        host_header = {
          values = ["demo-merchant.dev.revenge-games.com"]
        },
        path_pattern = {
          values = ["/*"]
        }
      }]
    },

    # nginx = {
    #   image                              = "nginx"
    #   mount_points                       = []
    #   healthcheck_path                   = "/"
    #   alb_disable                        = false
    #   volume                             = []
    #   health_check_grace_period_seconds  = 60
    #   deployment_minimum_healthy_percent = 100
    #   deployment_maximum_percent         = 200
    #   cpu                                = 1024
    #   mem                                = 2048
    #   desired_count                      = 1
    #   security_group_ids                 = [module.service_sg.security_group_id]
    #   environment = [
    #     {
    #       name  = "NGINX_PORT",
    #       value = "8080"
    #     }
    #   ]
    #   secrets = [
    #     {
    #       name      = "SPRING_R2DBC_URL"
    #       valueFrom = "${data.aws_secretsmanager_secret.dev_pg_server_env.arn}:SPRING_R2DBC_URL::"
    #     },
    #     {
    #       name      = "SPRING_R2DBC_USERNAME"
    #       valueFrom = "${data.aws_secretsmanager_secret.dev_pg_server_env.arn}:SPRING_R2DBC_USERNAME::"
    #     },
    #     {
    #       name      = "SERVER_PORT"
    #       valueFrom = "${data.aws_secretsmanager_secret.dev_pg_server_env.arn}:SERVER_PORT::"
    #     },
    #     {
    #       name      = "SPRING_R2DBC_PASSWORD"
    #       valueFrom = "${data.aws_secretsmanager_secret.dev_pg_server_env.arn}:SPRING_R2DBC_PASSWORD::"
    #     }
    #   ]
    #   enable_autoscaling       = true
    #   autoscaling_min_capacity = 1
    #   autoscaling_max_capacity = 256
    #   command                  = []
    #   health_check             = {}
    #   port_mappings = [
    #     {
    #       name          = "nginx"
    #       appProtocol   = "http"
    #       containerPort = 8080
    #       hostPort      = 8080
    #       protocol      = "tcp"
    #     }
    #   ]
    #   conditions = [{
    #     host_header = {
    #       values = ["payment.dev.revenge-games.com"]
    #     },
    #     path_pattern = {
    #       values = ["/*"]
    #     }
    #   }]
    # }
  }
}

resource "aws_cloudwatch_log_group" "pg_services" {
  for_each = local.pg_services
  name     = "${local.environment}-${each.key}"

}

resource "aws_service_discovery_http_namespace" "this" {
  name        = "${local.environment}-${local.project_name}"
  description = "CloudMap namespace for ${local.environment}-${local.project_name}"
}


module "container_definition_pg_services" {
  source = "../../modules/container-definition"

  for_each = local.pg_services
  name     = "${local.environment}-${each.key}"

  essential = true

  cpu    = each.value.cpu
  memory = each.value.mem
  image  = each.value.image

  environment  = each.value.environment
  secrets      = each.value.secrets
  command      = each.value.command
  health_check = each.value.health_check

  create_cloudwatch_log_group = false
  enable_cloudwatch_logging   = false
  log_configuration = {
  }

  memory_reservation                     = 100
  cloudwatch_log_group_retention_in_days = 5

  port_mappings = each.value.port_mappings

  mount_points = each.value.mount_points


  readonly_root_filesystem = false

}




module "ecs_pg_services" {
  source   = "github.com/terraform-aws-modules/terraform-aws-ecs.git?ref=v5.0.0//modules/service"
  for_each = local.pg_services
  # Service
  name = each.key

  family = "${local.environment}-${each.key}"

  cluster_arn = module.ecs.arn
  launch_type = "FARGATE"

  container_definition_defaults = {
    cloudwatch_log_group_retention_in_days = 7
    cloudwatch_log_group_name              = aws_cloudwatch_log_group.pg_services["${each.key}"].name
    create_cloudwatch_log_group            = false
    enable_cloudwatch_logging              = true
    log_configuration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.pg_services["${each.key}"].name
        awslogs-region        = local.aws_region
        awslogs-stream-prefix = "ecs"
        max-buffer-size       = "1m"
      }
    }
  }

  container_definitions = {
    (each.key) = module.container_definition_pg_services[each.key].container_definition
  }

  #   platform_version = "LATEST"
  create_task_exec_iam_role          = false
  iam_role_use_name_prefix           = false
  task_exec_iam_role_use_name_prefix = false
  tasks_iam_role_use_name_prefix     = false
  security_group_use_name_prefix     = false
  create_tasks_iam_role              = false
  # create_task_definition = false
  cpu                               = each.value.cpu
  memory                            = each.value.mem
  enable_execute_command            = true
  desired_count                     = each.value.desired_count
  health_check_grace_period_seconds = each.value.health_check_grace_period_seconds
  task_exec_iam_role_arn            = module.ecs_task_role.iam_role_arn
  tasks_iam_role_arn                = module.ecs_task_role.iam_role_arn
  iam_role_arn                      = module.ecs_service_role.iam_role_arn
  subnet_ids                        = [module.vpc.private_subnets[0]]
  create_security_group             = false
  security_group_ids                = each.value.security_group_ids
  ignore_task_definition_changes    = false
  network_mode                      = "awsvpc"
  assign_public_ip                  = false
  #   volume                             = each.value.volume == null ? {} : each.value.volume
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  deployment_controller = {
    type = "ECS"
  }
  runtime_platform = {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  load_balancer = each.value.alb_disable == true ? {} : {
    service = {
      target_group_arn = module.alb.target_groups["${each.key}"].arn
      container_name   = "${local.environment}-${each.key}"
      container_port   = 8080
    }
  }

  enable_autoscaling       = each.value.enable_autoscaling
  autoscaling_min_capacity = each.value.enable_autoscaling == false ? null : each.value.autoscaling_min_capacity
  autoscaling_max_capacity = each.value.enable_autoscaling == false ? null : each.value.autoscaling_max_capacity
  autoscaling_policies = each.value.enable_autoscaling == false ? {} : {
    cpu = {
      policy_type = "TargetTrackingScaling"

      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageCPUUtilization"
        }
      }
    }
    memory = {
      policy_type = "TargetTrackingScaling"

      target_tracking_scaling_policy_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        }
      }
    }
  }

  service_connect_configuration = {
    namespace = aws_service_discovery_http_namespace.this.arn

    service = {
      client_alias = {
        port     = 80
        dns_name = each.key
      }
      port_name      = each.key
      discovery_name = each.key

    }
  }

  volume = each.value.volume
}
