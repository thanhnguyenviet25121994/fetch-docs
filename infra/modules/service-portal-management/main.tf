# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#     cloudflare = {
#       source  = "cloudflare/cloudflare"
#       version = "~> 4.0"
#     }
#   }
# }

# variable "app_name" {
#   type    = string
#   default = "portal-management"
# }

# variable "app_env" {
#   type = string
# }

# variable "app_dns" {
#   type = string
# }

# variable "value_dns" {
#   type = string
# }

# variable "image" {
#   type = string
# }

# variable "root_domain" {
#   type = string
# }

# variable "role" {
#   type = object({
#     arn = string
#   })
# }

# variable "network_configuration" {
#   type = object({
#     region = string
#     vpc = object({
#       id = string
#     })
#     subnets         = list(string),
#     security_groups = list(string),
#     load_balancer = object({
#       arn = string
#     })
#   })
# }

# variable "env" {
#   type    = map(string)
#   default = {}
# }

# data "cloudflare_zone" "revenge" {
#   name = var.root_domain
# }

# resource "cloudflare_record" "this" {
#   zone_id = data.cloudflare_zone.revenge.id
#   name    = var.app_dns
#   value   = var.value_dns
#   type    = "CNAME"
#   proxied = true
# }

# resource "aws_lb_target_group" "this" {
#   name        = "${var.app_env}-${var.app_name}"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = var.network_configuration.vpc.id
#   target_type = "ip"

#   health_check {
#     path                = "/"
#     healthy_threshold   = 5
#     unhealthy_threshold = 5
#   }

#   tags = {
#     Environment = var.app_env
#   }
# }

# resource "aws_cloudwatch_log_group" "this" {
#   name = "${var.app_env}-${var.app_name}"

#   tags = {
#     Environment = "${var.app_env}"
#   }
# }

# resource "aws_ecs_cluster" "this" {
#   name = "${var.app_env}-${var.app_name}"

#   tags = {
#     Environment = var.app_env
#   }
# }

# data "aws_service_discovery_http_namespace" "env" {
#   name = var.app_env
# }

# resource "aws_ecs_service" "this" {
#   name            = var.app_name
#   cluster         = aws_ecs_cluster.this.id
#   task_definition = aws_ecs_task_definition.service.arn

#   launch_type   = "FARGATE"
#   desired_count = 1

#   network_configuration {
#     subnets          = var.network_configuration.subnets
#     security_groups  = var.network_configuration.security_groups
#     assign_public_ip = true
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.this.arn
#     container_name   = var.app_name
#     container_port   = 80
#   }

#   service_connect_configuration {
#     enabled   = true
#     namespace = data.aws_service_discovery_http_namespace.env.name
#   }

#   tags = {
#     Environment = var.app_env
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
#   task_role_arn      = var.role.arn

#   container_definitions = jsonencode([{
#     name      = var.app_name
#     image     = var.image
#     cpu       = 256
#     memory    = 512
#     essential = true
#     portMappings = [{
#       containerPort = 80
#       hostPort      = 80
#       protocol      = "tcp"
#     }]
#     environment = concat([{
#       name  = "VITE_REDIRECT_URI"
#       value = "https://bo.dev.revenge-games.com/"
#     }, 
#     {
#       name  = "VITE_AWS_SCOPE"
#       value = "aws.cognito.signin.user.admin openid dev-entity/entity-management"
#     },
#     {
#       name  = "VITE_AWS_BASE_URL"
#       value = "https://revengegamesdev.auth.ap-southeast-1.amazoncognito.com"
#     }, {
#       name  = "VITE_AWS_CLIENT_ID"
#       value = "r5isk01c2or5qgkh4kef6moqn"
#     }])
#     logConfiguration = {
#       logDriver = "awslogs"
#       options = {
#         "awslogs-group"         = aws_cloudwatch_log_group.this.name
#         "awslogs-region"        = var.network_configuration.region
#         "awslogs-stream-prefix" = "ecs"
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

# output "lb_target_group" {
#   value = aws_lb_target_group.this
# }
