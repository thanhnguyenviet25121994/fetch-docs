##############
### service-game-crash
#############
module "staging_service_game_crash" {
  source = "../../modules/service-adaptor"

  task_size_cpu    = "512"
  task_size_memory = "1024"

  app_name = "service-game-crash"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-crash:v1.0.9.1"

  env = {
    PLAYER_ONLINE_EXPIRY   = "PT2H"
    SERVER_PORT            = 9300
    SERVICE_ENTITY_ADDRESS = "http://service-entity-grpc:81"
    SERVICE_GAME_URL       = "http://service-game-client"
    SPRING_DATA_REDIS_URL  = "rediss://staging-valkey-nnlcn8.serverless.apne1.cache.amazonaws.com:6379"
  }

  role = aws_iam_role.staging_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.staging_networking.vpc
    subnets = [
      module.staging_networking.subnet_private_1.id,
      module.staging_networking.subnet_private_2.id
    ]
    security_groups = [
      module.staging_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.staging_service_game_crash.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}

resource "aws_lb_target_group" "staging_service_game_crash" {
  name        = "${local.environment}-service-game-crash"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.staging_networking.vpc.id
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


resource "aws_lb_listener_rule" "staging_service_game_crash" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 51

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_game_crash.arn
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



module "staging_service_gma_adaptor" {
  source = "../../modules/service-adaptor"

  task_size_cpu    = "512"
  task_size_memory = "1024"

  app_name = "service-gma-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-gma-adaptor:v1.0.14.1"

  env = {
    SERVER_PORT            = 9300
    SPRING_DATA_REDIS_URL  = "rediss://staging-valkey-nnlcn8.serverless.apne1.cache.amazonaws.com:6379"
    SERVICE_ENTITY_ADDRESS = "http://service-entity-grpc:81"

  }

  public_route = true
  role         = aws_iam_role.staging_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.staging_networking.vpc
    subnets = [
      module.staging_networking.subnet_private_1.id,
      module.staging_networking.subnet_private_2.id
    ]
    security_groups = [
      module.staging_networking.vpc.default_security_group_id
    ]

    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.staging_service_gma_adaptor.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}

resource "aws_lb_target_group" "staging_service_gma_adaptor" {
  name        = "${local.environment}-service-gma-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.staging_networking.vpc.id
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


resource "aws_lb_listener_rule" "staging_service_gma_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1080

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_gma_adaptor.arn
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
        "gma.sandbox.revenge-games.com",
      ]
    }
  }

  tags = {
    Name        = "service_game_crash"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "staging_service_gma_adaptor" {
  zone_id = data.cloudflare_zone.root.id
  name    = "gma.sandbox"
  value   = aws_lb.staging.dns_name
  type    = "CNAME"

  proxied = true
}