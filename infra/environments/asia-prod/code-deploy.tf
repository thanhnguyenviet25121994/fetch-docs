##### code deploy
module "codedeploy" {
  source = "../../modules/codedeploy"

  env = local.environment

  app_name                = "service-game-client-test"
  ecs_cluster_name        = module.prod_asia_service_game_client_test.get_aws_ecs_cluster.name
  ecs_service_name        = module.prod_asia_service_game_client_test.get_aws_ecs_service.name
  alb_listener_arn        = aws_lb_listener.http.arn
  target_group_blue_name  = aws_lb_target_group.prod_asia_service_game_client_blue.name
  target_group_green_name = aws_lb_target_group.prod_asia_service_game_client_green.name
  deployment_config_name  = aws_codedeploy_deployment_config.linear_5percent_every_5min.id
}

resource "aws_codedeploy_deployment_config" "linear_5percent_every_5min" {
  deployment_config_name = "Linear5PercentEvery5Min"
  compute_platform       = "ECS"

  traffic_routing_config {
    type = "TimeBasedLinear"

    time_based_linear {
      interval   = 5 # minutes between increments
      percentage = 5 # percentage of traffic shifted each interval
    }
  }

}

module "prod_asia_service_game_client_test" {
  providers = {
    aws = aws.current
  }

  source        = "../../modules/service-game-client-canary"
  desired_count = 1

  app_name = "service-game-client-test"

  task_size_cpu    = 2048
  task_size_memory = 4096

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-client:v1.0.1662.1"

  db = {
    endpoint        = aws_rds_cluster.prod_asia_main.endpoint
    reader_endpoint = aws_rds_cluster.prod_asia_main.reader_endpoint
    credentials     = data.aws_secretsmanager_secret.prod_asia_service_game_client_db
    name            = "service_game_client"
  }

  env = {
    FEATURES_REPLAY_PP                      = "https://g.pragmaticpplay.com"
    SERVICE_SHARED_UI_URL                   = "https://uig.rg-lgna.com"
    APP_KINESIS_STREAM_NAME                 = "prod_asia_bet_result_stream"
    SPRING_CASSANDRA_LOCAL_DATACENTER       = "ap-southeast-1"
    JAVA_OPTS                               = "-Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dlogging.level.com.revenge.game.features.play=OFF -Dlogging.level.com.revenge.game.features.play.WinningReportService=INFO"
    SPRING_CASSANDRA_CONTACT_POINTS         = "cassandra.ap-southeast-1.amazonaws.com:9142"
    SPRING_CASSANDRA_REQUEST_CONSISTENCY    = "local_quorum"
    SYSTEM_DEBUG_ENABLED                    = "false"
    FEATURES_REPLAY_RC                      = "https://uig.rg-lgna.com"
    SPRING_DATA_REDIS_URL                   = "rediss://prod-asia-valkey-diqjla.serverless.apse1.cache.amazonaws.com:6379"
    SERVICE_WEBSOCKET_ENVURL                = "https://apitest.rg-lgna.com"
    FEATURES_PLAY_OPERATOR_CLIENT_DEBUG     = "false"
    FEATURES_PLAY_LOGIC_CLIENT_VALIDATE     = "false"
    FEATURES_REPLAY_PG                      = "https://static.1adz83lbv.com"
    LOGGING_LEVEL_COM_REVENGE_GAME_API      = "INFO"
    SYSTEM_LOGIC_VALIDATE                   = "false"
    FEATURES_REPLAY_RG                      = "https://uig.rg-lgna.com"
    SERVICE_WEBSOCKET_URL                   = "wss://apitest.rg-lgna.com/ws"
    SYSTEM_LOGIC_DEBUG                      = "false"
    MANAGEMENT_TRACING_SAMPLING_PROBABILITY = "0.1"
    SERVICE_ENTITY_ADDRESS                  = "https://entity.revenge-games.global"
    FEATURES_REPLAY_HS_API                  = "https://api.hacksawproduction.com/api"
    FEATURES_PROMOTION_CLIENT_URL           = "https://promo-api.rg-lgna.com"
    MANAGEMENT_TRACING_ENABLED              = "false"
    SPRING_CASSANDRA_KEYSPACE_NAME          = "prod_keyspace"
    FEATURES_REPLAY_HS                      = "https://static.hacksawproduction.com/replay-manager"
    SERVICE_GAMEREPLAY_ENDPOINT             = "https://replay.rg-aslgna.com/replay/"
    SERVICE_COMMON_ASSETS_URL               = "https://rgg.rg-lgna.com/common-assets"
    FEATURES_REPLAY_PG_API                  = "https://m.1adz83lbv.com"
  }


  role = aws_iam_role.prod_asia_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prod_asia_networking.vpc
    subnets = [
      module.prod_asia_networking.subnet_private_1.id,
      module.prod_asia_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prod_asia_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [
      {
        arn  = aws_lb_target_group.prod_asia_service_game_client_blue.arn,
        port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_asia_service_game_client_blue" {
  name        = "${local.environment}-sgc-blue"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_asia_networking.vpc.id
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

resource "aws_lb_target_group" "prod_asia_service_game_client_green" {
  name        = "${local.environment}-sgc-green"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_asia_networking.vpc.id
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




resource "aws_lb_listener_rule" "prod_asia_service_game_client_test" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 512

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_game_client_blue.arn

  }

  condition {
    host_header {
      values = ["apitest.rg-lgna.com"]
    }
  }

  lifecycle {
    ignore_changes = [action]
  }


}


resource "cloudflare_record" "prod_asia_service_game_client_test" {
  zone_id = data.cloudflare_zone.rg.id
  name    = "apitest"
  content = aws_lb.prod_asia.dns_name
  type    = "CNAME"
  proxied = true
}








# locals {
#   # Clean and truncate name to 32 chars
#   tg_name = substr(
#     replace(
#       "${local.environment}-sgc-private",
#       "/[^a-zA-Z0-9-]/",
#       ""
#     ),
#     0,
#     32 - 6 # Reserve space for -blue/-green suffix
#   )
# }


# resource "aws_lb_target_group" "sgc_private_blue" {
#   name        = "${local.tg_name}-blue"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = module.prod_asia_networking.vpc.id
#   target_type = "ip"

#   health_check {
#     path                = "/actuator/health"
#     healthy_threshold   = 5
#     unhealthy_threshold = 10
#   }

#   tags = {
#     Environment = local.environment
#   }
# }

# resource "aws_lb_target_group" "sgc_private_green" {
#   name        = "${local.tg_name}-green"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = module.prod_asia_networking.vpc.id
#   target_type = "ip"

#   health_check {
#     path                = "/actuator/health"
#     healthy_threshold   = 5
#     unhealthy_threshold = 10
#   }

#   tags = {
#     Environment = local.environment
#   }
# }


# resource "aws_lb_listener_rule" "sgc_private" {
#   listener_arn = aws_lb_listener.http_private.arn
#   priority     = 512

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.sgc_private_blue.arn

#   }

#   condition {
#     host_header {
#       values = ["service-game-client-test.revenge-games.global"]
#     }
#   }

#   lifecycle {
#     ignore_changes = [action]
#   }

# }