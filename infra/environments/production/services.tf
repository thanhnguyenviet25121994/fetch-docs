resource "aws_service_discovery_http_namespace" "prod" {
  name = local.environment
}

data "aws_secretsmanager_secret" "prod_service_game_client_db" {
  name = "${local.environment}/service-game-client/db"
}

data "aws_ecr_image" "service_game_client" {
  repository_name = "revengegames/service-game-client"
  most_recent     = true
}

module "prod_service_game_client" {
  source = "../../modules/service-game-client-2"
  providers = {
    aws = aws.current
  }

  instance_count_min = 3
  task_size_cpu      = 2048
  task_size_memory   = 4096

  retention_in_days = 30

  app_env        = local.environment
  filter_pattern = "ERROR -\"o.s.w.reactive.socket.WebSocketHandler\" -\"Session mismatch\" -\"UNKNOWN\" -\"Missing bet setting\" -\"PlayServiceV2\" \"mahjong-fortune\" -\"bikini-babes\" -\"mermaid\" -\"run-pug-run\" -\"mochi-mochi\" -\"pandora\" -\"rave-on\" -\"samba-fiesta\" -\"sanguo\" -\"stallion-gold\" -\"sexy-christmas\""

  image = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-client:${local.service_game_client_version}"

  # db = {
  #   endpoint        = aws_rds_cluster.prod_main.endpoint
  #   reader_endpoint = aws_rds_cluster.prod_main.reader_endpoint
  #   credentials     = data.aws_secretsmanager_secret.prod_service_game_client_db
  #   name            = "service_game_client"
  # }

  env = {
    "APP_KINESIS_STREAM_NAME"                 = "prod_bet_result_stream"
    "FEATURES_PLAY_LOGIC_CLIENT_DEBUG"        = false
    "FEATURES_PLAY_LOGIC_CLIENT_VALIDATE"     = false
    "FEATURES_PLAY_OPERATOR_CLIENT_DEBUG"     = false
    "FEATURES_PROMOTION_CLIENT_URL"           = "https://promotion.rg-lgna.com"
    "FEATURES_REPLAY_HS"                      = "https://static.hacksawproduction.com/replay-manager"
    "FEATURES_REPLAY_HS_API"                  = "https://api.hacksawproduction.com/api"
    "FEATURES_REPLAY_PG"                      = "https://static.1adz83lbv.com"
    "FEATURES_REPLAY_PG_API"                  = "https://m.1adz83lbv.com"
    "FEATURES_REPLAY_PP"                      = "https://g.pragmaticpplay.com"
    "FEATURES_REPLAY_RC"                      = "https://uig.rg-lgna.com"
    "FEATURES_REPLAY_RG"                      = "https://uig.rg-lgna.com"
    "JAVA_OPTS"                               = "-Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dlogging.level.com.revenge.game.features.play=OFF -Dlogging.level.com.revenge.game.features.play.WinningReportService=INFO"
    "LOGGING_LEVEL_COM_REVENGE_GAME_API"      = "INFO"
    "MANAGEMENT_TRACING_ENABLED"              = false
    "MANAGEMENT_TRACING_SAMPLING_PROBABILITY" = 0.1
    "PLAYER_ONLINE_EXPIRY"                    = "PT2H"
    "SERVER_PORT"                             = 9300
    "SERVICE_COMMON_ASSETS_URL"               = "https://rgg.rg-lgna.com/common-assets"
    "SERVICE_ENTITY_ADDRESS"                  = "https://entity.revenge-games.global"
    "SERVICE_SHARED_UI_URL"                   = "https://uig.rg-lgna.com"
    "SERVICE_WEBSOCKET_ENVURL"                = "https://api.rg-lgna.com"
    "SERVICE_WEBSOCKET_URL"                   = "wss://api.rg-lgna.com/ws"
    "SPRING_CASSANDRA_CONTACT_POINTS"         = "cassandra.sa-east-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_KEYSPACE_NAME"          = "prod_keyspace"
    "SPRING_CASSANDRA_LOCAL_DATACENTER"       = "sa-east-1"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY"    = "local_quorum"
    "SPRING_DATA_REDIS_URL"                   = "rediss://prod-valkey-a5rxt5.serverless.sae1.cache.amazonaws.com:6379"
    "SYSTEM_LOGIC_DEBUG"                      = false
    "SYSTEM_DEBUG_ENABLED"                    = false
  }

  role = aws_iam_role.prod_service
  network_configuration = {
    region = local.region
    vpc    = module.prod_networking.vpc
    subnets = [
      module.prod_networking.subnet_private_1.id,
      module.prod_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prod_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_service_game_client.arn,
      port = 9300
    }]
  }

  services = {

  }

  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_service_game_client_dashboard" {
  name        = "${local.environment}-retry-dashboard"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_networking.vpc.id
  target_type = "ip"

  health_check {
    path                = "/actuator/health"
    port                = "9300"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  tags = {
    Environment = local.environment
  }
}

# resource "aws_lb_listener_rule" "prod_service_game_client_dashboard" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 207

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.prod_service_game_client_dashboard.arn
#   }

#   condition {
#     host_header {
#       values = ["retry.${local.root_domain}"]
#     }
#   }

#   tags = {
#     Name        = "retry.${local.environment}.${local.root_domain}"
#     Environment = "${local.environment}"
#   }
# }

resource "aws_lb_target_group" "prod_service_game_client" {
  name        = "${local.environment}-service-game-client"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_networking.vpc.id
  target_type = "ip"

  health_check {
    path                = "/actuator/health"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  slow_start = 30

  tags = {
    Environment = local.environment
  }
}


############
### service-game-client-2
############



module "prod_service_game_client_2" {
  source = "../../modules/service-game-client-new"
  providers = {
    aws = aws.current
  }

  instance_count_min = 1
  task_size_cpu      = 2048
  task_size_memory   = 4096
  app_name           = "service-game-client-2"
  ecs_cluster_arn    = module.prod_service_game_client.get_aws_ecs_cluster.arn

  app_env        = local.environment
  filter_pattern = "{ $.message = \"[ERROR]\" && $.message != \"*Error during WebSocket session*\" && $.message != \"*Handling error for session*\" }"

  image = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-client:v1.0.1735.1"


  # opensearch = {
  #   endpoint    = module.prod_opensearch_2.endpoint
  #   credentials = data.aws_secretsmanager_secret.prod_service_game_client_db
  # }


  env = {
    "APP_KINESIS_STREAM_NAME"                 = "prod_bet_result_stream"
    "FEATURES_PLAY_LOGIC_CLIENT_DEBUG"        = "false"
    "FEATURES_PLAY_LOGIC_CLIENT_VALIDATE"     = "false"
    "FEATURES_PLAY_OPERATOR_CLIENT_DEBUG"     = "false"
    "FEATURES_PROMOTION_CLIENT_URL"           = "https://promo-api.rg-lgna.com"
    "FEATURES_REPLAY_HS"                      = "https://static.hacksawproduction.com/replay-manager"
    "FEATURES_REPLAY_HS_API"                  = "https://api.hacksawproduction.com/api"
    "FEATURES_REPLAY_PG"                      = "https://static.1adz83lbv.com"
    "FEATURES_REPLAY_PG_API"                  = "https://m.1adz83lbv.com"
    "FEATURES_REPLAY_PP"                      = "https://g.pragmaticpplay.com"
    "FEATURES_REPLAY_RC"                      = "https://uig.rg-lgna.com"
    "FEATURES_REPLAY_RG"                      = "https://uig.rg-lgna.com"
    "JAVA_OPTS"                               = "-Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dlogging.level.com.revenge.game.features.play=OFF -Dlogging.level.com.revenge.game.features.play.WinningReportService=INFO"
    "LOGGING_LEVEL_COM_REVENGE_GAME_API"      = "INFO"
    "MANAGEMENT_TRACING_ENABLED"              = "false"
    "MANAGEMENT_TRACING_SAMPLING_PROBABILITY" = "0.1"
    "PLAYER_ONLINE_EXPIRY"                    = "PT2H"
    "SERVER_PORT"                             = "9300"
    "SERVICE_COMMON_ASSETS_URL"               = "https://rgg.rg-lgna.com/common-assets"
    "SERVICE_ENTITY_ADDRESS"                  = "https://entity.revenge-games.global"
    "SERVICE_SHARED_UI_URL"                   = "https://uig.rg-lgna.com"
    "SERVICE_WEBSOCKET_ENVURL"                = "https://apig.rg-lgna.com"
    "SERVICE_WEBSOCKET_URL"                   = "wss://api.rg-lgna.com/ws"
    "SPRING_CASSANDRA_CONTACT_POINTS"         = "cassandra.sa-east-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_KEYSPACE_NAME"          = "prod_keyspace"
    "SPRING_CASSANDRA_LOCAL_DATACENTER"       = "sa-east-1"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY"    = "local_quorum"
    "SPRING_DATA_REDIS_URL"                   = "rediss://prod-valkey-a5rxt5.serverless.sae1.cache.amazonaws.com:6379"
    "SPRING.CODEC.MAX-IN-MEMORY-SIZE"         = "20MB"
    "SYSTEM_DEBUG_ENABLED"                    = "false"
    "SYSTEM_LOGIC_DEBUG"                      = "false"
  }

  role = aws_iam_role.prod_service
  network_configuration = {
    region = local.region
    vpc    = module.prod_networking.vpc
    subnets = [
      module.prod_networking.subnet_private_1.id,
      module.prod_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prod_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_service_game_client_2.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_service_game_client_2" {
  name        = "${local.environment}-service-game-client-2"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_networking.vpc.id
  target_type = "ip"

  health_check {
    path                = "/actuator/health"
    port                = "9300"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  tags = {
    Environment = local.environment
  }
}

resource "aws_lb_listener_rule" "prod_service_game_client_2" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_game_client_2.arn
  }

  condition {
    host_header {
      values = ["api2.${local.root_domain}"]
    }
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  tags = {
    Name        = "api2.${local.root_domain}"
    Environment = "${local.environment}"
  }
}
resource "cloudflare_record" "api2" {
  zone_id = data.cloudflare_zone.root.id
  name    = "api2.${local.root_domain}"
  value   = aws_lb.prod.dns_name
  type    = "CNAME"
  proxied = true
}


resource "cloudflare_record" "api" {
  zone_id = data.cloudflare_zone.root.id
  name    = "api.${local.root_domain}"
  value   = aws_lb.prod.dns_name
  type    = "CNAME"
  proxied = true
}

# service-entity
data "aws_secretsmanager_secret" "prod_service_entity_db" {
  name = "${local.environment}/service-entity/db"
}

module "prod_service_entity" {
  source = "../../modules/service-entity"
  providers = {
    aws = aws.current
  }

  app_name = "service-entity-2"
  app_env  = local.environment
  image    = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-entity:${local.service_entity_version}"
  db = {
    endpoint    = aws_rds_cluster.prod_main.endpoint
    credentials = data.aws_secretsmanager_secret.prod_service_entity_db
    name        = "service_entity"
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
      arn  = aws_lb_target_group.prod_service_entity_http.arn,
      port = 9500
    }]
  }

  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_service_entity_http" {
  name        = "${local.environment}-service-entity-http"
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

resource "aws_lb_listener_rule" "prod_service_entity_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 600

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_entity_http.arn
  }

  condition {
    host_header {
      values = ["entity.${local.environment}.${local.root_domain}", "bo.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "entity.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_target_group" "prod_service_entity_grpc" {
  name             = "${local.environment}-service-entity-grpc"
  port             = 80
  protocol         = "HTTP"
  protocol_version = "GRPC"
  vpc_id           = module.prod_networking.vpc.id
  target_type      = "ip"

  health_check {
    path                = "/actuator/health"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  tags = {
    Environment = local.environment
  }
}


##############
### service-pp-adaptor
#############
module "prod_service_pp_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-pp-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-pp-adaptor:latest"

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
      arn  = aws_lb_target_group.prod_service_pp_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_service_pp_adaptor" {
  name        = "${local.environment}-service-pp-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_networking.vpc.id
  target_type = "ip"

  health_check {
    path                = "/health-check"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  tags = {
    Environment = local.environment
  }
}

resource "aws_lb_listener_rule" "prod_service_pp_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 209

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_pp_adaptor.arn
  }

  condition {
    host_header {
      values = ["g.pragmaticpplay.com", "pragmaticpplay.com"]
    }
  }

  tags = {
    Name        = "pp.${local.root_domain}"
    Environment = "${local.environment}"
  }
}


################
### Metabase
################
# data "aws_secretsmanager_secret" "prod_service_metabase_db" {
#   name = "${local.environment}/service-metabase/mb"
# }

# module "prod_service_metabase" {
#   source = "../../modules/service-metabase"
#   providers = {
#     aws = aws.current
#   }


#   cluster_arn = module.prod_service_game_client.get_aws_ecs_cluster.arn

#   instance_count_min = 1

#   app_env = local.environment
#   image   = "211125478834.dkr.ecr.ap-southeast-1.amazonaws.com/revengegames/metabase-clickhouse:v0.53.1"
#   db = {
#     endpoint    = aws_rds_cluster.prod_main.endpoint
#     credentials = data.aws_secretsmanager_secret.prod_service_metabase_db
#     name        = "service_metabase"
#   }

#   env = {
#   }

#   role = aws_iam_role.prod_service
#   network_configuration = {
#     region = local.region
#     vpc    = module.prod_networking.vpc
#     subnets = [
#       module.prod_networking.subnet_private_1.id,
#       module.prod_networking.subnet_private_2.id
#     ]
#     security_groups = [
#       module.prod_networking.vpc.default_security_group_id
#     ]
#     load_balancer_target_groups = [{
#       arn  = aws_lb_target_group.prod_service_metabase.arn,
#       port = 3000
#     }]
#   }

#   depends_on = [
#     aws_iam_role.prod_service,
#     aws_iam_role_policy.prod_service_policy,
#   ]
# }
# resource "aws_lb_target_group" "prod_service_metabase" {
#   name        = "${local.environment}-service-metabase"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = module.prod_networking.vpc.id
#   target_type = "ip"

#   health_check {
#     path                = "/api/health"
#     healthy_threshold   = 5
#     unhealthy_threshold = 10
#   }

#   tags = {
#     Environment = local.environment
#   }
# }

# resource "aws_lb_listener_rule" "prod_service_metabase" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 700

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.prod_service_metabase.arn
#   }

#   condition {
#     host_header {
#       values = ["mb.${local.root_domain}"]
#     }
#   }

#   tags = {
#     Name        = "mb.${local.root_domain}"
#     Environment = "${local.environment}"
#   }
# }

# resource "cloudflare_record" "prod_metabase" {
#   zone_id = data.cloudflare_zone.root.id
#   name    = "mb.${local.root_domain}"
#   value   = aws_lb.prod.dns_name
#   type    = "CNAME"
#   proxied = true
# }







#### import ALB listener rule
resource "aws_lb_listener_rule" "rc_launcher_authen" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 48

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.prod_service_game_client.arn
      }
      stickiness {
        enabled  = false
        duration = 3600
      }
    }
  }


  condition {
    host_header {
      values = ["rc.${local.root_domain}"]
    }
  }
  condition {
    path_pattern {
      values = ["/api/v1/launcher/authenticate"]
    }
  }

  tags = {
    Name        = "rc-launcher-authen"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "env_config_testing" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 101

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.prod_service_game_client.arn
      }
      stickiness {
        enabled  = false
        duration = 3600
      }
    }
  }


  condition {
    host_header {
      values = ["rc.${local.root_domain}", "as.${local.root_domain}", "rg.rg-lgna.com"]
    }
  }
  condition {
    path_pattern {
      values = ["/api/v1/client/*/env-config.*.js", "/api/v1/client/*/env-config.js"]
    }
  }

  tags = {
    Name        = "env-config-testing"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "api_balance" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 99

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.prod_service_game_client.arn
      }
      stickiness {
        enabled  = false
        duration = 3600
      }
    }
  }


  condition {
    host_header {
      values = ["api.${local.root_domain}"]
    }
  }
  condition {
    path_pattern {
      values = ["/api/v2/balance"]
    }
  }

  tags = {
    Name        = "/api/v2/balance"
    Environment = "${local.environment}"
  }
}

locals {
  game_domains = [
    "rg.rg-lgna.com",
    "rc.rg-lgna.com",
    "as.rg-lgna.com",
    # "ca.rg-lgna.com",
  ]
}




resource "aws_lb_listener_rule" "prod_service_game_client_3" {
  for_each = toset(local.game_domains)

  listener_arn = aws_lb_listener.http.arn
  priority     = 201 + index(local.game_domains, each.value)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        each.value
      ]
    }
  }

  condition {
    path_pattern {
      values = [
        "/*/spin",
        "/*/config",
        "/client/*",
        "/api/*",
      ]
    }
  }

  tags = {
    Name        = "srv-game-client-${index(local.game_domains, each.value)}"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "prod_service_game_client_4" {
  for_each = toset(local.game_domains)

  listener_arn = aws_lb_listener.http.arn
  priority     = 231 + index(local.game_domains, each.value)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        each.value
      ]
    }
  }

  condition {
    path_pattern {
      values = [
        "/client/player/authorize-game",
        "/*/config.json",
        "/client/game/*"
      ]
    }
  }

  tags = {
    Name        = "srv-game-client-${index(local.game_domains, each.value)}"
    Environment = "${local.environment}"
  }
}


resource "aws_lb_listener_rule" "prod_service_game_client" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        "api.${local.root_domain}",
        "rgg.rg-lgna.com",
        "rcg.rg-lgna.com",
        "asg.rg-lgna.com",
        "apig.rg-lgna.com"
      ]
    }
  }

  tags = {
    Name        = "api.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "env_config" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 97

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.prod_service_game_client.arn
      }
      stickiness {
        enabled  = false
        duration = 3600
      }
    }
  }


  condition {
    host_header {
      values = ["rgg.${local.root_domain}", "rcg.${local.root_domain}", "asg.${local.root_domain}"]
    }
  }
  condition {
    path_pattern {
      values = ["/api/v1/client/*/env-config.*.js", "/api/v1/client/*/env-config.js"]
    }
  }

  tags = {
    Name        = "env-config"
    Environment = "${local.environment}"
  }
}

# Lobby
resource "aws_lb_listener_rule" "lobby" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 48000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_game_client.arn
  }

  condition {
    host_header {
      values = ["lobby.rg-lgna.com", "lobby.revenge-games.com", "pxplay88.com"]
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



resource "aws_lb_listener_rule" "px88_lobby" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 48001

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_game_client.arn
  }

  condition {
    host_header {
      values = ["${local.pxplay88_domain}"]
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
    Name        = "${local.pxplay88_domain}"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "share_ui" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 39001

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_game_client.arn
  }

  condition {
    host_header {
      values = ["share-ui-game-client.rg-lgna.com", "uig.rg-lgna.com"]
    }
  }

  condition {
    path_pattern {
      values = [
        "/api/*"
      ]
    }
  }

  tags = {
    Name        = "share_ui"
    Environment = "${local.environment}"
  }
}



##############
### service-pgs-adaptor
#############
module "prod_service_pgs_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-pgs-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-pgs-adaptor:v1.0.34.1"

  env = {
    SGC_HOST            = "http://service-game-client",
    API_HOST            = "https://api.${local.pgs_domain}",
    DISABLE_CACHE       = "true"
    M_HOST              = "https://m.${local.pgs_domain}"
    STATIC_HOST         = "https://static.${local.pgs_domain}"
    SGC_REQUEST_TIMEOUT = 10000
    GAME_CODE_PREFIX    = "pgs-"
    RG_ENV              = ""
    ERROR_MESSAGE       = "true"
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
      arn  = aws_lb_target_group.prod_service_pgs_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_service_pgs_adaptor" {
  name        = "${local.environment}-service-pgs-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_networking.vpc.id
  target_type = "ip"

  health_check {
    path                = "/health-check"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  tags = {
    Environment = local.environment
  }
}

resource "aws_lb_listener_rule" "prod_service_pgs_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 190

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_pgs_adaptor.arn
  }

  condition {
    host_header {
      values = ["api.${local.pgs_domain}"]
    }
  }

  tags = {
    Name        = "${local.pgs_domain}"
    Environment = "${local.environment}"
  }
}




##############
### service-wf-adapter
#############
module "prod_service_wf_adapter" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-wf-adapter"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-wf-adapter:v1.0.7.1"

  env = {
    JAVA_OPTS                  = "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    SERVICE_GAMECLIENT_ADDRESS = "https://api.rg-lgna.com"
    WEB_CLIENT_HOST            = "https://wf.rg-lgna.com"
    SERVICE_ENTITY_ADDRESS     = "http://service-entity-2-grpc.prod:81"

    SERVICE_WFGAMING_SECRET      = "ISLK5OV0V9H12W65"
    SERVICE_WFGAMING_OPERATOR_ID = "wfRGstgBRL"
    SERVICE_WFGAMING_ADDRESS     = "https://smakermicsvc.back138.com/api/opgateway/v1/op/"
    SERVICE_WFGAMING_DEBUG       = "true"
    # game.client config
    SERVICE_GAMECLIENT_DEBUG = "true"
    SPRING_DATA_REDIS_URL    = "rediss://prod-valkey-a5rxt5.serverless.sae1.cache.amazonaws.com:6379"
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
      arn  = aws_lb_target_group.prod_service_wf_adapter.arn,
      port = 9900
    }]
  }

  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_service_wf_adapter" {
  name        = "${local.environment}-service-wf-adapter"
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

resource "aws_lb_listener_rule" "prod_service_wf_adapter" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 221

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_wf_adapter.arn
  }

  condition {
    host_header {
      values = ["wf.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "wf.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "prod_service_wf_adapter" {
  zone_id = data.cloudflare_zone.root.id
  name    = "wf"
  content = "af88f7c2d37bfb364.awsglobalaccelerator.com"
  type    = "CNAME"
  proxied = true
}


##############
### service-transfer-wallet
#############
module "prod_service_transfer_wallet" {
  providers = {
    aws = aws.current
  }

  task_size_cpu    = "2048"
  task_size_memory = "4096"

  source = "../../modules/service-transfer-wallet"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-transfer-wallet:v1.0.78.1"

  env = {
    "SPRING_CASSANDRA_KEYSPACE_NAME" : "prod_keyspace"
    "SPRING_CASSANDRA_CONTACT_POINTS" : "cassandra.sa-east-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY" : "local_quorum"
    "SPRING_CASSANDRA_LOCAL_DATACENTER" : "sa-east-1"
    "JAVA_OPTS" : "-Dlogging.level.com.linecorp.armeria.client.logging=DEBUG -Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dlogging.level.com.revenge.game.features.operator=DEBUG -Dsystem.logic.debug=true -Dlogging.level.com.linecorp.armeria.client.logging=DEBUG -XX:MaxDirectMemorySize=134217728 -Dfeatures.history.impl=cassandra -Dspring.cassandra.keyspace-name=prod_keyspace -Dspring.cassandra.contact-points=cassandra.sa-east-1.amazonaws.com:9142 -Dspring.cassandra.request.consistency=local_quorum -Dspring.cassandra.local-datacenter=sa-east-1",
    "SPRING_DATA_REDIS_URL" : "rediss://prod-valkey-a5rxt5.serverless.sae1.cache.amazonaws.com:6379"
    "SERVER_PORT" : "9300"
    "PORT" : "9300"
    "SERVICE_ENTITY_ADDRESS" : "https://entity.revenge-games.global"
    "SYSTEM_SIGNATURE_HOST" : "apig.rg-lgna.com"
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
      arn  = aws_lb_target_group.prod_service_transfer_wallet.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_service_transfer_wallet" {
  name        = "${local.environment}-service-transfer-wallet"
  port        = 9300
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

resource "aws_lb_listener_rule" "prod_service_transfer_wallet" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_transfer_wallet.arn
  }

  condition {
    host_header {
      values = [
        "apig.${local.root_domain}",
        "apibrl.${local.root_domain}"
      ]
    }
  }
  condition {
    path_pattern {
      values = ["/api/v1/transfer/*"]
    }
  }

  tags = {
    Name        = "transfer-wallet"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "prod_service_transfer_wallet" {
  zone_id = data.cloudflare_zone.root.id
  name    = "tw"
  content = aws_lb.prod.dns_name
  type    = "CNAME"
  proxied = true
}



##############
### service-hacksaw-adaptor
#############
module "prod_service_hacksaw_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-hacksaw-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-hacksaw-adaptor:v1.0.32.1"


  env = {
    LOG_LEVEL                      = "info"
    NODE_ENV                       = "production"
    SGC_HOST                       = "http://service-game-client"
    SERVICE_CLIENT_REQUEST_TIMEOUT = "10000"
    GAME_CODE_PREFIX               = "hs-"
    API_HOST                       = "https://api.${local.hacksaw_domain}"
    STATIC_HOST                    = "https://static.${local.hacksaw_domain}"
    PORT                           = "8080"
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
      arn  = aws_lb_target_group.prod_service_hacksaw_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_service_hacksaw_adaptor" {
  name        = "${local.environment}-service-hacksaw-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_networking.vpc.id
  target_type = "ip"

  health_check {
    path                = "/health-check"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  tags = {
    Environment = local.environment
  }
}

resource "aws_lb_listener_rule" "prod_service_hacksaw_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 220

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_hacksaw_adaptor.arn
  }

  condition {
    host_header {
      values = ["api.${local.hacksaw_domain}"]
    }
  }

  tags = {
    Name        = "api.${local.hacksaw_domain}"
    Environment = "sandbox"
  }
}



##############
### service-jili-adapter
#############
module "prod_service_jili_adapter" {
  providers = {
    aws = aws.current
  }

  task_size_cpu    = "2048"
  task_size_memory = "4096"

  source = "../../modules/service-jili-adapter"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-jili-adapter:v1.0.14.1"


  env = {
    JAVA_OPTS : "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    SERVICE_GAMECLIENT_ADDRESS = "http://service-game-client"
    WEB_CLIENT_HOST            = "https://jili.${local.root_domain}"
    SERVICE_ENTITY_ADDRESS     = "https://entity.revenge-games.global"

    SERVICE_WFGAMING_SECRET      = "ISLK5OV0V9H12W65"
    SERVICE_WFGAMING_OPERATOR_ID = "wfRGstgBRL"
    SERVICE_WFGAMING_ADDRESS     = "https://smakermicsvc.back138.com/api/opgateway/v1/op/"
    SPRING_DATA_REDIS_URL        = "rediss://prod-valkey-a5rxt5.serverless.sae1.cache.amazonaws.com:6379"

    SERVICE_WFGAMING_DEBUG = "true"
    # game.client config
    SERVICE_GAMECLIENT_DEBUG = "true"
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
      arn  = aws_lb_target_group.prod_service_jili_adapter.arn,
      port = 9945
    }]
  }

  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_service_jili_adapter" {
  name        = "${local.environment}-service-jili-adapter"
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

resource "aws_lb_listener_rule" "prod_service_jili_adapter" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_jili_adapter.arn
  }

  condition {
    host_header {
      values = ["jili.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "jili.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "prod_service_jili_adapter" {
  zone_id = data.cloudflare_zone.root.id
  name    = "jili"
  content = "af88f7c2d37bfb364.awsglobalaccelerator.com"
  type    = "CNAME"
  proxied = true
}


######
# service-kinesis-consumer-report
module "prod_service_kinesis_consumer_report" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-kinesis-consumer-report"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-kinesis-consumer-report:20250616-local"


  env = {

    "CLICKHOUSE_ENDPOINT" : "http://10.90.113.175:8123",
    "CLICKHOUSE_USERNAME" : "default",
    "CLICKHOUSE_PASSWORD" : "b0lyjr6nynjpfag8iakfpw5s",
    "PROCESSOR_STREAM" : "prod_bet_result_stream",
    "PROCESSOR_REGION" : "sa-east-1",
    "PROCESSOR_NAME" : "ReportConsumerApplication-20250708",
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
  }

  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
  ]
}