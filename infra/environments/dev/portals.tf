data "aws_ecr_image" "portal_management" {
  repository_name = "revengegames/portal-magement"
  most_recent     = true
}

module "dev_portal_management" {
  source = "../../modules/game"
  providers = {
    aws = aws.current
  }

  app_env                             = local.environment
  app_name                            = "bo"
  api_url                             = "https://api.dev.revenge-games.com"
  assets_url                          = "https://assets.dev.revenge-games.com"
  domain                              = "bo.dev.revenge-games.com"
  cloudfront_distribution_domain_name = "d3j2z4dq99kqb0.cloudfront.net"
}


# module "dev_portal_replay" {
#   source = "../../modules/portal-replay"
#   providers = {
#     aws = aws.current
#   }

#   app_env   = local.environment
#   domain    = "replay.${local.environment}.${local.root_domain}"
#   image     = "211125478834.dkr.ecr.ap-southeast-1.amazonaws.com/revengegames/portal-replay:v1.0.1.1"
#   value_dns = aws_lb.dev.dns_name
#   app_dns   = "replay.${local.environment}.${local.root_domain}"
#   role      = aws_iam_role.dev_service

#   network_configuration = {
#     region = "${local.region}"
#     vpc    = module.dev_networking.vpc
#     subnets = [
#       module.dev_networking.subnet_private_1.id,
#       module.dev_networking.subnet_private_2.id
#     ]
#     security_groups = [
#       module.dev_networking.vpc.default_security_group_id
#     ]
#     load_balancer = aws_lb.dev
#   }

#   depends_on = [
#     aws_iam_role.dev_service,
#     aws_iam_role_policy.dev_service_policy,
#   ]
# }

resource "aws_lb_listener_rule" "dev_lobby" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 48000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_game_client.arn
  }

  condition {
    host_header {
      values = ["lobby.dev.${local.root_domain}"]
    }
  }

  condition {
    path_pattern {
      values = [
        "/api/v1/*"
      ]
    }
  }

  tags = {
    Name        = "lobby.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

# data "aws_ecr_image" "portal_operator" {
#   repository_name = "revengegames/portal-operator"
#   most_recent     = true
# }

# module "dev_portal_operator" {
#   source = "../../modules/portal"
#   providers = {
#     aws = aws.current
#   }

#   app_env  = local.environment
#   app_name = "op"
#   image =
# }

resource "aws_lb_listener_rule" "dev_portal_op_envconfig" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30000

  # action {
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.dev_service_game_client.arn
  # }

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/javascript"
      status_code  = 200
      message_body = <<EOT
window._env_ = {
  __API_URL__: "https://op.dev.revenge-games.com/api",
  __AWS_BASE_URL__:
    "https://revengegamesdev.auth.ap-southeast-1.amazoncognito.com",
  __AWS_CLIENT_ID__: "r5isk01c2or5qgkh4kef6moqn",
  __AWS_SCOPE__:
    "aws.cognito.signin.user.admin openid dev-entity/entity-management",
  __REDIRECT_URI__: "https://op.dev.revenge-games.com",
};
EOT
    }
  }

  condition {
    host_header {
      values = ["op.*"]
    }
  }

  condition {
    path_pattern {
      values = [
        "/env-config.js",
      ]
    }
  }

  tags = {
    Name        = "portal-operator-envconfig"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "dev_portal_op_api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 35001

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_entity_http.arn
  }

  condition {
    host_header {
      values = ["op.*"]
    }
  }

  condition {
    path_pattern {
      values = [
        "/api/v1/*",
      ]
    }
  }

  tags = {
    Name        = "portal-operator-api"
    Environment = "${local.environment}"
  }
}



locals {
  pxplay_domain = "pxplaygaming.com"
}


# resource "cloudflare_record" "portal_operator_2" {
#   zone_id = data.cloudflare_zone.pxplay.id
#   name    = "op.dev"
#   content = aws_lb.dev.dns_name
#   type    = "CNAME"
#   proxied = false
# }
data "aws_secretsmanager_secret" "dev_service_operator_2" {
  name = "${local.environment}/service-portal-operator-2/credentials"
}

module "portal_operator_2" {
  source = "../../modules/portal-operator-2"
  providers = {
    aws = aws.current
  }

  app_env = local.environment
  domain  = "op.dev.${local.pxplay_domain}"
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/portal-operator-2:v1.0.649.1"
  role    = aws_iam_role.dev_service

  env = {
    "DATABASE_DIALECT" : "postgres",
    "LOG_LEVEL" : "DEBUG",
    "CLICKHOUSE_URL" : "http://54.178.243.185:8123",
    "CLICKHOUSE_USERNAME" : "default",
    "CLICKHOUSE_DATABASE" : "operator_portal",
    "NODE_OPTIONS" : "--max-old-space-size=2048",
    "NODE_ENV" : "production",
    "PORT" : 3000,
    "PROMOTION_URL" : "https://promotion.dev.revenge-games.com"
    "PROMOTION_HOST_NAME" : "promotion.dev.revenge-games.com",
  }

  secrets = {
    credentials = data.aws_secretsmanager_secret.dev_service_operator_2
  }

  network_configuration = {
    region = "${local.region}"
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
    load_balancer = aws_lb.dev
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}
