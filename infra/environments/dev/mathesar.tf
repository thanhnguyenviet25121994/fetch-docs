
# locals {
#   # policy_file = "${abspath("${path.module}/template")}/ecs_task_exec.json.tpl"
#   mathesar_domain = "mathesar.dev.revenge-games.com"
#   mathesar_services_alb = {
#     mathesar-caddy = {
#       image            = "public.ecr.aws/z4n6p6m0/mathesar-caddy:0.2.1"
#       mount_points     = []
#       healthcheck_path = "/health-check"
#       alb_disable      = false
#       mount_points = [
#         {
#           sourceVolume  = "media-volume",
#           containerPath = "/code/media"
#         },
#         {
#           sourceVolume  = "static-volume",
#           containerPath = "/code/static"
#         },
#         {
#           sourceVolume  = "data-volume",
#           containerPath = "/data"
#         }
#       ]


#       volume = [
#         {
#           name = "data-volume"
#           efs_volume_configuration = {
#             file_system_id     = aws_efs_file_system.mathesar_shared_fs.id
#             transit_encryption = "ENABLED"
#             authorization_config = {
#               access_point_id = aws_efs_access_point.mathesar_shared_access_point.id
#             }
#           }
#         },
#         {
#           name = "media-volume"
#           efs_volume_configuration = {
#             file_system_id     = aws_efs_file_system.mathesar_shared_fs.id
#             transit_encryption = "ENABLED"
#             authorization_config = {
#               access_point_id = aws_efs_access_point.mathesar_shared_media.id
#             }
#           }
#         },
#         {
#           name = "static-volume"
#           efs_volume_configuration = {
#             file_system_id     = aws_efs_file_system.mathesar_shared_fs.id
#             transit_encryption = "ENABLED"
#             authorization_config = {
#               access_point_id = aws_efs_access_point.mathesar_shared_static.id
#             }
#           }
#         }
#       ]
#       health_check_grace_period_seconds  = 0
#       deployment_minimum_healthy_percent = 100
#       deployment_maximum_percent         = 200
#       cpu                                = 256
#       mem                                = 512
#       desired_count                      = 1
#       security_group_ids                 = [module.dev_networking.vpc.default_security_group_id]
#       environment = [
#         { name = "DOMAIN_NAME", value = "http://${local.mathesar_domain}" },
#         { name = "MATHESAR_SERVICE", value = "mathesar-http" },
#         { name = "MATHESAR_SERVICE_PORT", value = "8000" }
#       ]
#       secrets                  = []
#       enable_autoscaling       = true
#       autoscaling_min_capacity = 1
#       autoscaling_max_capacity = 256
#       command                  = []
#       health_check             = {}
#       service_connect_configuration = [
#         {
#           port   = 80
#           suffix = "http"
#         }
#       ]
#       port_mappings = [
#         {
#           name          = "mathesar-caddy-http"
#           appProtocol   = "http"
#           containerPort = 80
#           hostPort      = 80
#           protocol      = "tcp"
#         }
#       ]
#     },
#   }

#   mathesar_services = merge(local.mathesar_services_alb, {
#     mathesar = {
#       image = "public.ecr.aws/z4n6p6m0/mathesar:0.2.1"
#       #   image                              = "nginx:1.25.4"
#       mount_points                       = []
#       healthcheck_path                   = "/"
#       alb_disable                        = true
#       volume                             = []
#       health_check_grace_period_seconds  = 0
#       deployment_minimum_healthy_percent = 100
#       deployment_maximum_percent         = 200
#       cpu                                = 1024
#       mem                                = 2048
#       desired_count                      = 1
#       security_group_ids                 = [module.dev_networking.vpc.default_security_group_id]
#       environment = [
#         # { name= "DOMAIN_NAME", value= "https://${local.mathesar_domain}" },
#         { name = "POSTGRES_DB", value = "mathesar_django" },
#         { name = "CSRF_TRUSTED_ORIGINS", value = "https://${local.mathesar_domain}" },
#         { name = "POSTGRES_HOST", value = "${aws_rds_cluster.dev_main.endpoint}" },
#         { name = "POSTGRES_PORT", value = "5432" },
#         { name = "DJANGO_SETTINGS_MODULE", value = "config.settings.production" },
#         { name = "ALLOWED_HOSTS", value = "*" },
#         { name = "DEBUG", value = "true" }
#       ],
#       secrets = [
#         {
#           name      = "POSTGRES_PASSWORD"
#           valueFrom = "${data.aws_secretsmanager_secret.mathesar.arn}:POSTGRES_PASSWORD::"
#         },
#         {
#           name      = "SECRET_KEY"
#           valueFrom = "${data.aws_secretsmanager_secret.mathesar.arn}:SECRET_KEY::"
#         },
#         {
#           name      = "POSTGRES_USER"
#           valueFrom = "${data.aws_secretsmanager_secret.mathesar.arn}:POSTGRES_USER::"
#         },
#       ]
#       enable_autoscaling       = true
#       autoscaling_min_capacity = 1
#       autoscaling_max_capacity = 256
#       command                  = []
#       health_check             = {}
#       service_connect_configuration = [
#         {
#           port   = 8000
#           suffix = "http"
#         }
#       ]
#       port_mappings = [
#         {
#           name          = "mathesar-http"
#           appProtocol   = "http"
#           containerPort = 8000
#           hostPort      = 8000
#           protocol      = "tcp"
#         }
#       ]
#     },

#   })
# }



# ######################
# ####### mathesar EFS
# #####################
# resource "aws_efs_file_system" "mathesar_shared_fs" {
#   creation_token = "${local.environment}-mathesar-shared-efs"
#   tags = {
#     Name = "${local.environment}-mathesar-shared-efs"
#   }
# }

# resource "aws_efs_access_point" "mathesar_shared_access_point" {
#   file_system_id = aws_efs_file_system.mathesar_shared_fs.id
#   root_directory {
#     creation_info {
#       owner_gid   = 0
#       owner_uid   = 0
#       permissions = 755
#     }
#     path = "/caddy/data"
#   }
# }
# resource "aws_efs_access_point" "mathesar_shared_media" {
#   file_system_id = aws_efs_file_system.mathesar_shared_fs.id
#   root_directory {
#     creation_info {
#       owner_gid   = 0
#       owner_uid   = 0
#       permissions = 755
#     }
#     path = "/caddy/code/media"
#   }
# }
# resource "aws_efs_access_point" "mathesar_shared_static" {
#   file_system_id = aws_efs_file_system.mathesar_shared_fs.id
#   root_directory {
#     creation_info {
#       owner_gid   = 0
#       owner_uid   = 0
#       permissions = 755
#     }
#     path = "/caddy/code/static"
#   }
# }

# resource "aws_efs_mount_target" "mathesar_efs_target" {
#   file_system_id  = aws_efs_file_system.mathesar_shared_fs.id
#   subnet_id       = module.dev_networking.subnet_private_1.id
#   security_groups = [module.dev_networking.vpc.default_security_group_id]
# }

# data "aws_secretsmanager_secret" "mathesar" {
#   name = "${local.environment}/mathesar/env"
# }

# module "mathesar_service_role" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
#   version = "v5.33.0"

#   role_name             = "${local.environment}-mathesar-ecs-service"
#   role_description      = "Roles for ${local.environment} ecs-service}"
#   create_role           = true
#   role_requires_mfa     = false
#   trusted_role_services = ["ec2.amazonaws.com"]
#   custom_role_policy_arns = [
#     "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",
#   ]
# }

# module "mathesar_task_role" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
#   version = "v5.33.0"

#   role_name             = "${local.environment}-mathesar-ecs-task-role"
#   role_description      = "Roles for ${local.environment} ecs-task-role}"
#   create_role           = true
#   role_requires_mfa     = false
#   trusted_role_services = ["ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
#   custom_role_policy_arns = [
#     "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
#   ]
# }

# resource "aws_iam_role_policy" "mathesar_inline" {
#   name = "${local.environment}-mathesar-ecs-task-role"
#   role = module.mathesar_task_role.iam_role_name
#   policy = templatefile(local.policy_file, {
#     s3_resources = jsonencode(local.s3_resources)
#   })
# }


# ########################################

# resource "aws_cloudwatch_log_group" "mathesar_services" {
#   for_each = local.mathesar_services
#   name     = "${local.environment}-${each.key}"

# }

# resource "aws_lb_target_group" "mathesar_services" {
#   for_each    = local.mathesar_services_alb
#   name        = "${local.environment}-${each.key}"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = module.dev_networking.vpc.id
#   target_type = "ip"

#   health_check {
#     path                = each.value.healthcheck_path
#     healthy_threshold   = 5
#     unhealthy_threshold = 10
#   }

#   tags = {
#     Environment = local.environment
#   }
# }

# resource "aws_lb_listener_rule" "mathesar_services" {
#   for_each = local.mathesar_services_alb

#   listener_arn = aws_lb_listener.http.arn
#   priority     = 2010 + index(keys(local.mathesar_services_alb), each.key) + 1

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.mathesar_services[each.key].arn
#   }

#   condition {
#     host_header {
#       values = ["${local.mathesar_domain}"]
#     }
#   }

#   tags = {
#     Environment = "${local.environment}"
#   }
# }

# module "container_definition_mathesar_services" {
#   source = "../../modules/task-definition"

#   for_each = local.mathesar_services
#   name     = "${local.environment}-${each.key}"

#   essential = true

#   cpu    = each.value.cpu
#   memory = each.value.mem
#   image  = each.value.image

#   environment                 = each.value.environment
#   secrets                     = each.value.secrets
#   command                     = each.value.command
#   health_check                = each.value.health_check
#   create_cloudwatch_log_group = false
#   enable_cloudwatch_logging   = false
#   log_configuration = {
#   }

#   memory_reservation                     = 100
#   cloudwatch_log_group_retention_in_days = 5

#   port_mappings = each.value.port_mappings

#   mount_points = each.value.mount_points


#   readonly_root_filesystem = false

# }




# module "ecs_mathesar_services" {
#   source   = "../../modules/ecs-service"
#   for_each = local.mathesar_services
#   # Service
#   name = each.key

#   family = "${local.environment}-${each.key}"

#   cluster_arn = module.ecs_mathesar.arn
#   launch_type = "FARGATE"

#   container_definition_defaults = {
#     cloudwatch_log_group_retention_in_days = 7
#     cloudwatch_log_group_name              = aws_cloudwatch_log_group.mathesar_services["${each.key}"].name
#     create_cloudwatch_log_group            = false
#     enable_cloudwatch_logging              = true
#     log_configuration = {
#       logDriver = "awslogs"
#       options = {
#         awslogs-group         = aws_cloudwatch_log_group.mathesar_services["${each.key}"].name
#         awslogs-region        = local.region
#         awslogs-stream-prefix = "ecs"
#         max-buffer-size       = "1m"
#       }
#     }
#   }

#   container_definitions = {
#     (each.key) = module.container_definition_mathesar_services[each.key].container_definition
#   }

#   #   platform_version = "LATEST"
#   create_task_exec_iam_role          = false
#   iam_role_use_name_prefix           = false
#   task_exec_iam_role_use_name_prefix = false
#   tasks_iam_role_use_name_prefix     = false
#   security_group_use_name_prefix     = false
#   create_tasks_iam_role              = false
#   # create_task_definition = false
#   cpu                                = each.value.cpu
#   memory                             = each.value.mem
#   enable_execute_command             = true
#   desired_count                      = each.value.desired_count
#   health_check_grace_period_seconds  = each.value.health_check_grace_period_seconds
#   task_exec_iam_role_arn             = module.mathesar_task_role.iam_role_arn
#   tasks_iam_role_arn                 = module.mathesar_task_role.iam_role_arn
#   iam_role_arn                       = module.mathesar_service_role.iam_role_arn
#   subnet_ids                         = [module.dev_networking.subnet_private_1.id]
#   create_security_group              = false
#   security_group_ids                 = each.value.security_group_ids
#   ignore_task_definition_changes     = false
#   network_mode                       = "awsvpc"
#   assign_public_ip                   = false
#   deployment_minimum_healthy_percent = 100
#   deployment_maximum_percent         = 200
#   deployment_controller = {
#     type = "ECS"
#   }
#   #   runtime_platform = {
#   #     operating_system_family = "LINUX"
#   #     cpu_architecture        = "ARM64"
#   #   }
#   load_balancer = each.value.alb_disable == true ? {} : {
#     service = {
#       target_group_arn = aws_lb_target_group.mathesar_services["${each.key}"].arn
#       container_name   = "${local.environment}-${each.key}"
#       container_port   = 80
#     }
#   }

#   enable_autoscaling       = each.value.enable_autoscaling
#   autoscaling_min_capacity = each.value.enable_autoscaling == false ? null : each.value.autoscaling_min_capacity
#   autoscaling_max_capacity = each.value.enable_autoscaling == false ? null : each.value.autoscaling_max_capacity
#   autoscaling_policies = each.value.enable_autoscaling == false ? {} : {
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

#   service_connect_configuration = {
#     "config1" = {
#       namespace = "dev"
#       services = [
#         for service in each.value.service_connect_configuration : {
#           client_alias = [
#             {
#               port     = service.port
#               dns_name = "${each.key}-${service.suffix}"
#             }
#           ]
#           port_name      = "${each.key}-${service.suffix}"
#           discovery_name = "${each.key}-${service.suffix}"
#         }
#       ]
#     }
#   }

#   #   mount_points = each.value.mount_points

#   volume = each.value.volume
# }


# ############
# ## ECS cluster
# ############
# module "ecs_mathesar" {
#   source  = "terraform-aws-modules/ecs/aws//modules/cluster"
#   version = "v5.7.4"

#   cluster_name = "${local.environment}-mathesar"

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
# }
