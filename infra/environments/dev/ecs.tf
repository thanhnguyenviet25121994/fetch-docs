locals {
  ecr_repos = [
    "revengegames/service-marketing-portal-adapter",
    "revengegames/service-operator",
    "revengegames/service-pp-adaptor",
    "revengegames/service-pgs-adaptor",
    "revengegames/service-hacksaw-adaptor",
    "revengegames/service-firehose-stream-consumer",
    "revengegames/service-marketing-2",
    "revengegames/game-ui",
    "revengegames/service-transfer-wallet",
    "revengegames/service-wf-adapter",
    "revengegames/service-promotion",
    "revengegames/service-leaderboard",
    "revengegames/web-rectangle-games",
    "revengegames/service-jili-adapter",
    "revengegames/service-data-analyser",
    "revengegames/service-player-retention",
    "revengegames/service-killer-game-server",
    "revengegames/service-acewin-adaptor",
    "revengegames/service-rginternal",
    "revengegames/portal-rginternal",
    "revengegames/service-kinesis-consumer-report",
    "revengegames/service-game-crash",
    "revengegames/service-config-server",
    "revengegames/service-gma-adaptor"
  ]


}

data "aws_secretsmanager_secret" "dev_service_marketing_portal_adapter" {
  name = "${local.environment}/service-marketing-portal-adapter/env"
}

module "ecrs" {
  source  = "cloudposse/ecr/aws"
  version = "0.42.1"

  namespace = local.project
  stage     = local.environment
  name      = "app"

  image_names          = [for item in local.ecr_repos : "${item}"]
  image_tag_mutability = "MUTABLE"
  max_image_count      = 100
  # time_based_rotation  = true
  scan_images_on_push = false

}
module "ecrs_logic_rtp" {
  source  = "cloudposse/ecr/aws"
  version = "0.42.1"

  namespace = local.project
  stage     = local.environment
  name      = "app"

  image_names          = ["revengegames/logic"]
  image_tag_mutability = "MUTABLE"
  max_image_count      = 14
  time_based_rotation  = true
  scan_images_on_push  = false

}

# module "container_definition_service_marketing_portal_adapter" {
#   source = "../../modules/task-definition"

#   name = "service-marketing-portal-adapter"

#   essential = true

#   cpu    = 1024
#   memory = 2048
#   image  = "${module.ecrs.repository_url_map["revengegames/service-marketing-portal-adapter"]}:v1.0.56.1"

#   secrets = [
#     {
#       name      = "SPRING_R2DBC_URL_PRIMARY"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:SPRING_R2DBC_URL_PRIMARY::"
#     },
#     {
#       name      = "SPRING_R2DBC_URL_SECONDARY"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:SPRING_R2DBC_URL_SECONDARY::"
#     },
#     {
#       name      = "GAME_CLIENT_API"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:GAME_CLIENT_API::"
#     },
#     {
#       name      = "GAME_CLIENT_ASSET"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:GAME_CLIENT_ASSET::"
#     },
#     {
#       name      = "GAME_CLIENT_STATIC"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:GAME_CLIENT_STATIC::"
#     },
#     {
#       name      = "OPENSEARCH_URIS"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:OPENSEARCH_URIS::"
#     },
#     {
#       name      = "OPENSEARCH_USERNAME"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:OPENSEARCH_USERNAME::"
#     },
#     {
#       name      = "OPENSEARCH_PASSWORD"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:OPENSEARCH_PASSWORD::"
#     },
#     {
#       name      = "JWT_EXPIRATION"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:JWT_EXPIRATION::"
#     },
#     {
#       name      = "JWT_SECRET"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:JWT_SECRET::"
#     },
#     {
#       name      = "SERVER_PORT"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:SERVER_PORT::"
#     },
#     {
#       name      = "SPRING_R2DBC_URL_MAIN"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:SPRING_R2DBC_URL_MAIN::"
#     },
#     {
#       name      = "SPRING_R2DBC_URL_ENTITY"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:SPRING_R2DBC_URL_ENTITY::"
#     },
#     {
#       name      = "SPRING_R2DBC_URL_GAMECLIENT"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:SPRING_R2DBC_URL_GAMECLIENT::"
#     },
#     {
#       name      = "SPRING_R2DBC_MAIN_URL"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:SPRING_R2DBC_URL_MAIN::"
#     },
#     {
#       name      = "SPRING_R2DBC_ENTITY_URL"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:SPRING_R2DBC_URL_ENTITY::"
#     },
#     {
#       name      = "SPRING_R2DBC_GAMECLIENT_URL"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:SPRING_R2DBC_URL_GAMECLIENT::"
#     },
#     {
#       name      = "BACKOFFICE_CLIENTENV_LOBBYPAGEURL"
#       valueFrom = "${data.aws_secretsmanager_secret.dev_service_marketing_portal_adapter.arn}:BACKOFFICE_CLIENTENV_LOBBYPAGEURL::"
#     }
#   ]
#   log_configuration = {
#     logDriver = "awslogs"
#     options = {
#       awslogs-create-group = "true"
#       awslogs-group        = "/aws/ecs/${local.environment}-service-marketing-portal-adapter"
#       awslogs-region       = "${local.region}"
#     }
#   }

#   memory_reservation = 100

#   # For task definitions that use the awsvpc network mode, only specify the containerPort.
#   # The hostPort can be left blank or it must be the same value as the containerPort
#   port_mappings = [
#     {
#       name          = "service-marketing-portal-adapter"
#       containerPort = 9600
#       hostPort      = 9600
#       protocol      = "tcp"
#       appProtocol   = "http"
#     }
#   ]


#   # Example image used requires access to write to root filesystem
#   readonly_root_filesystem = false

# }

# module "dev_ecs_svc_service_marketing_portal_adapter" {
#   source  = "terraform-aws-modules/ecs/aws//modules/service"
#   version = "v5.7.4"

#   name = "service-marketing-portal-adapter"

#   family = "${local.environment}-service-marketing-portal-adapter"

#   container_definitions = {
#     service-marketing-portal-adapter = module.container_definition_service_marketing_portal_adapter.container_definition
#   }
#   cluster_arn      = module.dev_ecs_cluster_service_marketing_portal_adapter.arn
#   launch_type      = "FARGATE"
#   platform_version = "LATEST"

#   create_task_exec_iam_role = false
#   # create_task_definition = false
#   cpu                                = 1024
#   memory                             = 2048
#   enable_execute_command             = true
#   desired_count                      = 2
#   health_check_grace_period_seconds  = 30
#   create_tasks_iam_role              = false
#   task_exec_iam_role_arn             = aws_iam_role.dev_service.arn
#   tasks_iam_role_arn                 = aws_iam_role.dev_service.arn
#   iam_role_arn                       = aws_iam_role.dev_service.arn
#   subnet_ids                         = [module.dev_networking.subnet_private_1.id, module.dev_networking.subnet_private_2.id]
#   create_security_group              = false
#   security_group_ids                 = [module.dev_networking.vpc.default_security_group_id]
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
#     log_configuration = {
#       log_driver = "awslogs"
#       options = {
#         awslogs-create-group  = "true"
#         awslogs-group         = "/aws/ecs/${local.environment}-svc-connect-service-marketing-portal-adapter"
#         awslogs-region        = "${local.region}"
#         awslogs-stream-prefix = "ecs"
#       }
#     }
#     namespace = aws_service_discovery_http_namespace.dev.arn
#     service = {
#       client_alias = {
#         port     = 80
#         dns_name = "service-marketing-portal-adapter"
#       }
#       port_name      = "service-marketing-portal-adapter"
#       discovery_name = "service-marketing-portal-adapter"
#     }
#   }
#   load_balancer = {
#     service = {
#       target_group_arn = module.alb.target_groups["service-marketing-portal-adapter"].arn
#       container_name   = "service-marketing-portal-adapter"
#       container_port   = 9600
#     }
#   }

#   enable_autoscaling       = true
#   autoscaling_min_capacity = 1
#   autoscaling_max_capacity = 4
#   autoscaling_policies = {
#     cpu = {
#       policy_type = "TargetTrackingScaling"

#       target_tracking_scaling_policy_configuration = {
#         predefined_metric_specification = {
#           predefined_metric_type = "ECSServiceAverageCPUUtilization"
#         }
#       }
#     }
#     memory = {
#       policy_type = "TargetTrackingScaling"

#       target_tracking_scaling_policy_configuration = {
#         predefined_metric_specification = {
#           predefined_metric_type = "ECSServiceAverageMemoryUtilization"
#         }
#       }
#     }
#   }

#   depends_on = [module.container_definition_service_marketing_portal_adapter]
# }


# module "dev_ecs_cluster_service_marketing_portal_adapter" {
#   source  = "terraform-aws-modules/ecs/aws//modules/cluster"
#   version = "v5.7.4"

#   cluster_name = "${local.environment}-service-marketing-portal-adapter"

#   cluster_configuration = {
#     execute_command_configuration = {
#       logging = "OVERRIDE"
#       log_configuration = {
#         cloud_watch_log_group_name = "/aws/ecs/${local.environment}-service-marketing-portal-adapter"
#       }
#     }
#   }

#   fargate_capacity_providers = {
#     FARGATE = {
#       default_capacity_provider_strategy = {
#         weight = 100
#         base   = 20
#       }
#     }
#     # FARGATE_SPOT = {
#     #   default_capacity_provider_strategy = {
#     #     weight = 50
#     #   }
#     # }
#   }
#   tags = {
#     Project_Name = "${local.project}"
#     Environment  = "${local.environment}"
#     Terraform    = true
#   }
# }
