##############
### service-game-crash
#############
module "prod_service_game_crash" {
  source = "../../modules/service-adaptor"

  task_size_cpu    = "512"
  task_size_memory = "1024"

  app_name = "service-game-crash"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-crash:v1.0.58.1"

  env = {
    PLAYER_ONLINE_EXPIRY   = "PT2H"
    SERVER_PORT            = 9300
    SERVICE_ENTITY_ADDRESS = "https://entity.revenge-games.global"
    SERVICE_GAME_URL       = "http://service-game-client"
    SPRING_DATA_REDIS_URL  = "rediss://prod-valkey-a5rxt5.serverless.sae1.cache.amazonaws.com:6379"
    CRASH_BOT_MAX          = "300"
    CRASH_BOT_MIN          = "200"
  }

  role = aws_iam_role.prod_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prod_networking.vpc
    subnets = [
      module.prod_networking.subnet_private_1.id,
      module.prod_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prod_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_service_game_crash.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
    aws_lb_listener_rule.prod_service_game_crash
  ]
}

resource "aws_lb_target_group" "prod_service_game_crash" {
  name        = "${local.environment}-service-game-crash"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_networking.vpc.id
  target_type = "ip"

  health_check {
    path                = "/actuator/health"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  tags = {
    Environment = local.environment
  }
}

# resource "aws_lb_listener_rule" "prod_service_game_crash" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 1500

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.prod_service_game_crash.arn
#   }

#   condition {
#     host_header {
#       values = ["apicrash.${local.environment}.${local.root_domain}"]
#     }
#   }

#   tags = {
#     Name        = "apicrash.${local.environment}.${local.root_domain}"
#     Environment = "${local.environment}"
#   }
# }

# resource "cloudflare_record" "prod_service_game_crash" {
#   zone_id = data.cloudflare_zone.root.id
#   name    = "apicrash.prod"
#   value   = aws_lb.prod.dns_name
#   type    = "CNAME"
#   proxied = true
# }

resource "aws_lb_listener_rule" "prod_service_game_crash" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 51

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_game_crash.arn
  }

  condition {
    path_pattern {
      values = [
        "/com.revenge.entity.v1.PlayService",
        "/api/v1/*/leaderboard*",
        "/api/v1/*/players/stats",
      ]
    }
  }

  tags = {
    Name        = "service_game_crash"
    Environment = "${local.environment}"
  }
}


################# service-gma-adaptor
##############

module "prod_service_gma_adaptor" {
  source = "../../modules/service-adaptor"

  task_size_cpu    = "1024"
  task_size_memory = "2048"

  app_name = "service-gma-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-gma-adaptor:v1.0.29.1"

  env = {
    SERVER_PORT                       = 9300
    SPRING_DATA_REDIS_URL             = "rediss://prod-valkey-a5rxt5.serverless.sae1.cache.amazonaws.com:6379"
    SERVICE_ENTITY_ADDRESS            = "https://entity.revenge-games.global"
    GMA_PLATFORM_CLIENT_URL           = "https://gapi.gmslot8.com/v1/rectangle"
    GMA_PLATFORM_CLIENT_API_KEY       = "20cb5091-01ed-42a1-963d-18f83502aefc"
    GMA_PLATFORM_CLIENT_MERCHANT_CODE = "Rectangle"
    GMA_PLATFORM_CLIENT_BRAND_CODE    = "gmag"

  }

  public_route = true
  role         = aws_iam_role.prod_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prod_networking.vpc
    subnets = [
      module.prod_networking.subnet_private_1.id,
      module.prod_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prod_networking.vpc.default_security_group_id
    ]

    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_service_gma_adaptor.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_service_gma_adaptor" {
  name        = "${local.environment}-service-gma-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_networking.vpc.id
  target_type = "ip"

  health_check {
    path                = "/actuator/health"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  tags = {
    Environment = local.environment
  }
}


resource "aws_lb_listener_rule" "prod_service_gma_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1080

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_gma_adaptor.arn
  }

  condition {
    path_pattern {
      values = [
        "/*"
      ]
    }
  }
  condition {
    host_header {
      values = [
        "gma-api.rg-lgna.com",
      ]
    }
  }

  tags = {
    Name        = "service_gma"
    Environment = "${local.environment}"
  }
}
