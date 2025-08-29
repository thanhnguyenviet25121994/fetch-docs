##############
### service-game-crash
#############
module "mkt_service_game_crash" {
  source = "../../modules/service-adaptor"

  task_size_cpu    = "512"
  task_size_memory = "1024"

  app_name = "service-game-crash"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-crash:v1.0.76.1"

  env = {
    PLAYER_ONLINE_EXPIRY   = "PT2H"
    SERVER_PORT            = 9300
    SERVICE_ENTITY_ADDRESS = "https://entity.revenge-games.gmkt"
    SERVICE_GAME_URL       = "http://service-game-client"
    SPRING_DATA_REDIS_URL  = "rediss://mkt-valkey-a5rxt5.serverless.sae1.cache.amazonaws.com:6379"
    CRASH_BOT_MAX          = "300"
    CRASH_BOT_MIN          = "200"
    ENVS                   = "800"
  }

  role = aws_iam_role.mkt_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.mkt_networking.vpc
    subnets = [
      module.mkt_networking.subnet_private_1.id,
      module.mkt_networking.subnet_private_2.id
    ]
    security_groups = [
      module.mkt_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.mkt_service_game_crash.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.mkt_service,
    aws_iam_role_policy.mkt_service_policy,
    aws_lb_listener_rule.mkt_service_game_crash
  ]
}

resource "aws_lb_target_group" "mkt_service_game_crash" {
  name        = "${local.environment}-service-game-crash"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.mkt_networking.vpc.id
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


resource "aws_lb_listener_rule" "mkt_service_game_crash" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 51

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mkt_service_game_crash.arn
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


