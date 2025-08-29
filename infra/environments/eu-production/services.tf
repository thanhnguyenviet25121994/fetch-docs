resource "aws_service_discovery_http_namespace" "prd_eu" {
  name = local.environment
}

data "aws_secretsmanager_secret" "prd_eu_service_game_client_db" {
  name = "${local.environment}/service-game-client/db"
}

data "aws_ecr_image" "service_game_client" {
  repository_name = "revengegames/service-game-client"
  most_recent     = true
}

module "prd_eu_service_game_client" {
  source = "../../modules/service-game-client-2"
  providers = {
    aws = aws.current
  }

  instance_count_min = 2
  task_size_cpu      = 2048
  task_size_memory   = 4096

  app_name = "srv-game-client"

  app_env        = local.environment
  filter_pattern = "{ $.message = \"[ERROR]\" && $.message != \"*Error during WebSocket session*\" && $.message != \"*Handling error for session*\" }"

  image = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-client:v1.0.1733.1"

  env = {
    "APP_KINESIS_STREAM_NAME"                 = "prd_eu_bet_result_stream"
    "FEATURE_PLAY_LOGIC_CLIENT_DEBUG"         = false
    "FEATURES_PLAY_LOGIC_CLIENT_VALIDATE"     = false
    "FEATURE_PLAY_OPERATOR_CLIENT_DEBUG"      = false
    "FEATURES_HISTORY_IMPL"                   = "cassandra"
    "FEATURES_REPLAY_HS"                      = "https://static.hacksawproduction.com/replay-manager"
    "FEATURES_REPLAY_HS_API"                  = "https://api.hacksawproduction.com/api"
    "FEATURES_REPLAY_PG"                      = "https://static.1adz83lbv.com"
    "FEATURES_REPLAY_PG_API"                  = "https://m.1adz83lbv.com"
    "FEATURES_REPLAY_PP"                      = "https://g.pragmaticpplay.com"
    "FEATURES_REPLAY_RC"                      = "https://uig.rg-lgna.com"
    "FEATURES_REPLAY_RG"                      = "https://uig.rg-lgna.com"
    "FEATURES_PLAY_LOGIC_CLIENT_DEBUG"        = "false"
    "FEATURES_PLAY_LOGIC_CLIENT_VALIDATE"     = "false"
    "FEATURES_PLAY_OPERATOR_CLIENT_DEBUG"     = "false"
    "JAVA_OPTS"                               = "-Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dlogging.level.com.revenge.game.features.play=OFF"
    "LOGGING_LEVEL_COM_REVENGE_GAME_API"      = "INFO"
    "MANAGEMENT_TRACING_ENABLED"              = false
    "MANAGEMENT_TRACING_SAMPLING_PROBABILITY" = 0.1
    "PLAYER_ONLINE_EXPIRY"                    = "PT2H"
    "SERVER_PORT"                             = 9300
    "SERVICE_COMMON_ASSETS_URL"               = "https://rgg.rg-lgna.com/common-assets"
    "SERVICE_ENTITY_ADDRESS"                  = "https://entity.revenge-games.global"
    "SERVICE_GAMEREPLAY_ENDPOINT"             = "https://replay.lnga-rg.com/replay/"
    "SERVICE_SHARED_UI_URL"                   = "https://uig.rg-lgna.com"
    "SERVICE_WEBSOCKET_ENVURL"                = "https://api.rg-lgna.com"
    "SERVICE_WEBSOCKET_URL"                   = "wss://api.rg-lgna.com/ws"
    "SPRING_CASSANDRA_CONTACT_POINTS"         = "cassandra.eu-west-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_KEYSPACE_NAME"          = "prod_keyspace"
    "SPRING_CASSANDRA_LOCAL_DATACENTER"       = "eu-west-1"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY"    = "local_quorum"
    "SPRING_DATA_REDIS_URL"                   = "rediss://prd-eu-valkey-fe3a5n.serverless.euw1.cache.amazonaws.com:6379"
    "SPRING.CODEC.MAX-IN-MEMORY-SIZE"         = "20MB"
    "SYSTEM_DEBUG_ENABLED"                    = false
    "SYSTEM_ERROR_DEBUG"                      = false
    "SYSTEM_LOGIC_DEBUG"                      = false
    "SYSTEM_LOGIC_VALIDATE"                   = false
    "FEATURES_PROMOTION_CLIENT_URL"           = "https://promo-api.rg-lgna.com"
  }
  role = aws_iam_role.prd_eu_service
  network_configuration = {
    region = local.region
    vpc    = module.prd_eu_networking.vpc
    subnets = [
      module.prd_eu_networking.subnet_private_1.id,
      module.prd_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prd_eu_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prd_eu_service_game_client.arn,
      port = 9300
    }]
  }
  services = {
  }

  depends_on = [
    aws_iam_role.prd_eu_service,
    aws_iam_role_policy.prd_eu_service_policy,
  ]
}

resource "aws_lb_target_group" "prd_eu_service_game_client" {
  name        = "${local.environment}-srv-game-client"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prd_eu_networking.vpc.id
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

resource "aws_lb_listener_rule" "service_game_client_lobby" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 400

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        "lobby.${local.root_domain}",
        "lobbyg.${local.rg_domain}",
        "lobby.revenge-games.com",
        "pxplay88.com"
      ]
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
    Name        = "srv-game-client"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "srv_game_client_v1" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        "api.${local.root_domain}",
      ]
    }
  }

  condition {
    path_pattern {
      values = [
        "/api/*",
        "/client/*",
        "/*/config",
        "/*/spin",
      ]
    }
  }

  tags = {
    Name        = "srv-game-client-v1"
    Environment = "${local.environment}"
  }
}



resource "aws_lb_listener_rule" "srv_game_client_global" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 199

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        "apig.rg-lgna.com",
        "api.rg-lgna.com",
        "rgg.rg-lgna.com",
        "rcg.rg-lgna.com"
      ]
    }
  }

  condition {
    path_pattern {
      values = [
        "/*",
      ]
    }
  }

  tags = {
    Name        = "srv-game-client-global"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "service_game_client_asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        "asg.rg-lgna.com",
      ]
    }
  }

  condition {
    path_pattern {
      values = [
        "/*"
      ]
    }
  }

  tags = {
    Name        = "service-game-client-asg"
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
        arn = aws_lb_target_group.prd_eu_service_game_client.arn
      }
      stickiness {
        enabled  = false
        duration = 3600
      }
    }
  }


  condition {
    host_header {
      values = ["rgg.${local.rg_domain}", "rcg.${local.rg_domain}", "asg.${local.rg_domain}"]
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

locals {
  game_domains = [
    "rc.${local.root_domain}",
    "as.${local.root_domain}",
    "rg.${local.root_domain}",
  ]
}

resource "aws_lb_listener_rule" "srv_game_client_v2" {
  for_each = toset(local.game_domains)

  listener_arn = aws_lb_listener.http.arn
  priority     = 201 + index(local.game_domains, each.value)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_game_client.arn
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
        "/api/*",
        "/client/*",
        "/*/config",
        "/*/spin"
      ]
    }
  }

  tags = {
    Name        = "srv-game-client-${each.value}"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "srv_game_client_v3" {
  for_each = toset(local.game_domains)

  listener_arn = aws_lb_listener.http.arn
  priority     = 4001 + index(local.game_domains, each.value)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_game_client.arn
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
        "/config.json",
        "/config.json*",
        "/*/config.json"
      ]
    }
  }

  tags = {
    Name        = "srv-game-client-${each.value}"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "srv_game_client_v4" {
  for_each = toset(local.game_domains)

  listener_arn = aws_lb_listener.http.arn
  priority     = 4101 + index(local.game_domains, each.value)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_game_client.arn
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
        "/env-config.js",
        "/env-config.*.js",
        "/*/env-config.js",
        "/*/env-config.*.js"
      ]
    }
  }

  tags = {
    Name        = "srv-game-client-${each.value}"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "srv_game_client_history" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        "api.${local.root_domain}",
      ]
    }
  }

  condition {
    path_pattern {
      values = [
        "/*/bets",
        "/*/total-bets",
      ]
    }
  }

  tags = {
    Name        = "srv-game-client-history"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "srv_game_client_ws" {
  for_each = toset(local.game_domains)

  listener_arn = aws_lb_listener.http.arn
  priority     = 301 + index(local.game_domains, each.value)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_game_client.arn
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
        "/ws"
      ]
    }
  }

  tags = {
    Name        = "srv-game-client-ws-${each.value}"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "api" {
  zone_id = data.cloudflare_zone.root.id
  name    = "api.${local.root_domain}"
  content = aws_lb.prd_eu.dns_name
  type    = "CNAME"
  proxied = true
}



# service-game-client-2
module "prd_eu_service_game_client_2" {
  source = "../../modules/service-game-client-new"
  providers = {
    aws = aws.current
  }

  instance_count_min = 1
  task_size_cpu      = 2048
  task_size_memory   = 4096
  app_name           = "srv-game-client-2"
  ecs_cluster_arn    = module.prd_eu_service_game_client.get_aws_ecs_cluster.arn

  app_env        = local.environment
  filter_pattern = "{ $.message = \"[ERROR]\" && $.message != \"*Error during WebSocket session*\" && $.message != \"*Handling error for session*\" }"

  image = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-client:v1.0.1735.1"

  env = {
    "APP_KINESIS_STREAM_NAME"                 = "prd_eu_bet_result_stream"
    "FEATURE_PLAY_LOGIC_CLIENT_DEBUG"         = "false"
    "FEATURE_PLAY_LOGIC_CLIENT_VALIDATE"      = "false"
    "FEATURE_PLAY_OPERATOR_CLIENT_DEBUG"      = "true"
    "FEATURES_HISTORY_IMPL"                   = "cassandra"
    "FEATURES_PROMOTION_CLIENT_URL"           = "https://promo-api.rg-lgna.com"
    "FEATURES_REPLAY_HS"                      = "https://static.hacksawproduction.com/replay-manager"
    "FEATURES_REPLAY_HS_API"                  = "https://api.hacksawproduction.com/api"
    "FEATURES_REPLAY_PG"                      = "https://static.1adz83lbv.com"
    "FEATURES_REPLAY_PG_API"                  = "https://m.1adz83lbv.com"
    "FEATURES_REPLAY_PP"                      = "https://g.pragmaticpplay.com"
    "FEATURES_REPLAY_RC"                      = "https://uig.rg-lgna.com"
    "FEATURES_REPLAY_RG"                      = "https://uig.rg-lgna.com"
    "JAVA_OPTS"                               = "-Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dlogging.level.com.revenge.game.features.play=OFF"
    "LOGGING_LEVEL_COM_REVENGE_GAME_API"      = "INFO"
    "MANAGEMENT_TRACING_ENABLED"              = "false"
    "MANAGEMENT_TRACING_SAMPLING_PROBABILITY" = "0.1"
    "PLAYER_ONLINE_EXPIRY"                    = "PT2H"
    "SERVER_PORT"                             = "9300"
    "SERVICE_COMMON_ASSETS_URL"               = "https://rg.lnga-rg.com/common-assets"
    "SERVICE_ENTITY_ADDRESS"                  = "https://entity.revenge-games.global"
    "SERVICE_GAMEREPLAY_ENDPOINT"             = "https://replay.lnga-rg.com/replay/"
    "SERVICE_SHARED_UI_URL"                   = "https://ui.lnga-rg.com"
    "SERVICE_WEBSOCKET_ENVURL"                = "https://api.lnga-rg.com"
    "SERVICE_WEBSOCKET_URL"                   = "wss://api.lnga-rg.com/ws"
    "SPRING_CASSANDRA_CONTACT_POINTS"         = "cassandra.eu-west-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_KEYSPACE_NAME"          = "prod_keyspace"
    "SPRING_CASSANDRA_LOCAL_DATACENTER"       = "eu-west-1"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY"    = "local_quorum"
    "SPRING_DATA_REDIS_URL"                   = "rediss://prd-eu-valkey-fe3a5n.serverless.euw1.cache.amazonaws.com:6379"
    "SPRING.CODEC.MAX-IN-MEMORY-SIZE"         = "20MB"
    "SYSTEM_DEBUG_ENABLED"                    = "false"
    "SYSTEM_ERROR_DEBUG"                      = "false"
    "SYSTEM_LOGIC_DEBUG"                      = "false"
    "SYSTEM_LOGIC_VALIDATE"                   = "false"
  }

  role = aws_iam_role.prd_eu_service
  network_configuration = {
    region = local.region
    vpc    = module.prd_eu_networking.vpc
    subnets = [
      module.prd_eu_networking.subnet_private_1.id,
      module.prd_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prd_eu_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prd_eu_service_game_client_2.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.prd_eu_service,
    aws_iam_role_policy.prd_eu_service_policy,
  ]
}

resource "aws_lb_target_group" "prd_eu_service_game_client_2" {
  name        = "${local.environment}-srv-game-client-2"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prd_eu_networking.vpc.id
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

resource "aws_lb_listener_rule" "prd_eu_service_game_client_2" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_game_client_2.arn
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
  name    = "api2"
  value   = aws_lb.prd_eu.dns_name
  type    = "CNAME"
  proxied = true
}



# service-entity
data "aws_secretsmanager_secret" "prd_eu_service_entity_db" {
  name = "${local.environment}/service-entity/db"
}

module "prd_eu_service_entity" {
  source = "../../modules/service-entity"
  providers = {
    aws = aws.current
  }

  app_name = "srv-entity"
  app_env  = local.environment
  image    = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-entity:${local.service_entity_version}"
  role     = aws_iam_role.prd_eu_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prd_eu_networking.vpc
    subnets = [
      module.prd_eu_networking.subnet_private_1.id,
      module.prd_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prd_eu_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prd_eu_service_entity_http.arn,
      port = 9500
    }]
  }

  depends_on = [
    aws_iam_role.prd_eu_service,
    aws_iam_role_policy.prd_eu_service_policy,
  ]
}

resource "aws_lb_target_group" "prd_eu_service_entity_http" {
  name        = "${local.environment}-srv-entity-http"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prd_eu_networking.vpc.id
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

resource "aws_lb_listener_rule" "prd_eu_service_entity_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_entity_http.arn
  }

  condition {
    host_header {
      values = ["bo.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "bo.${local.root_domain}"
    Environment = "${local.environment}"
  }
}


##############
### service-pp-adaptor
#############
module "prd_eu_service_pp_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-pp-adaptor"

  app_name = "srv-pp-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-pp-adaptor:v1.0.291.1"

  env = {
    "SERVICE_CLIENT" = "https://apig.rg-lgna.com",
    "LOG_LEVEL"      = "info"
  }

  role = aws_iam_role.prd_eu_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prd_eu_networking.vpc
    subnets = [
      module.prd_eu_networking.subnet_private_1.id,
      module.prd_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prd_eu_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prd_eu_service_pp_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.prd_eu_service,
    aws_iam_role_policy.prd_eu_service_policy,
  ]
}

resource "aws_lb_target_group" "prd_eu_service_pp_adaptor" {
  name        = "${local.environment}-service-pp-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prd_eu_networking.vpc.id
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

resource "aws_lb_listener_rule" "prd_eu_service_pp_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 209

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_pp_adaptor.arn
  }

  condition {
    host_header {
      values = ["pp.${local.root_domain}", "apig.pragmaticpplay.com", "g.pragmaticpplay.com"]
    }
  }

  tags = {
    Name        = "pp.${local.root_domain}"
    Environment = "${local.environment}"
  }
}



##############
### service-pgs-adaptor
#############
module "prd_eu_service_pgs_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-pgs-adaptor"

  app_name = "srv-pgs-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-pgs-adaptor:v1.0.55.1"

  env = {
    SGC_HOST = "http://srv-game-client",
    API_HOST = "https://api.${local.pgs_dns}",
    # DISABLE_CACHE       = "true"
    M_HOST              = "https://m.${local.pgs_dns}"
    STATIC_HOST         = "https://static.${local.pgs_dns}"
    SGC_REQUEST_TIMEOUT = 10000
    GAME_CODE_PREFIX    = "pgs-"
    RG_ENV              = ""
    ERROR_MESSAGE       = "true"
  }

  role = aws_iam_role.prd_eu_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prd_eu_networking.vpc
    subnets = [
      module.prd_eu_networking.subnet_private_1.id,
      module.prd_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prd_eu_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prd_eu_service_pgs_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.prd_eu_service,
    aws_iam_role_policy.prd_eu_service_policy,
  ]
}

resource "aws_lb_target_group" "prd_eu_service_pgs_adaptor" {
  name        = "${local.environment}-service-pgs-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prd_eu_networking.vpc.id
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

resource "aws_lb_listener_rule" "prd_eu_service_pgs_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 190

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_pgs_adaptor.arn
  }

  condition {
    host_header {
      values = ["api.1adz83lbv.com"]
    }
  }

  tags = {
    Name        = "api.1adz83lbv.com"
    Environment = "${local.environment}"
  }
}


##############
### service-hacksaw-adaptor
#############
module "prd_eu_service_hacksaw_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-hacksaw-adaptor"

  app_name = "srv-hacksaw-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-hacksaw-adaptor:v1.0.39.1"


  env = {
    LOG_LEVEL                      = "error"
    NODE_ENV                       = "production"
    SGC_HOST                       = "http://srv-game-client"
    SERVICE_CLIENT_REQUEST_TIMEOUT = "10000"
    GAME_CODE_PREFIX               = "hs-"
    API_HOST                       = "https://api.${local.hacksaw_domain}"
    STATIC_HOST                    = "https://static.${local.hacksaw_domain}"
    PORT                           = "8080"
  }

  role = aws_iam_role.prd_eu_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prd_eu_networking.vpc
    subnets = [
      module.prd_eu_networking.subnet_private_1.id,
      module.prd_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prd_eu_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prd_eu_service_hacksaw_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.prd_eu_service,
    aws_iam_role_policy.prd_eu_service_policy,
  ]
}

resource "aws_lb_target_group" "prd_eu_service_hacksaw_adaptor" {
  name        = "${local.environment}-service-hacksaw-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prd_eu_networking.vpc.id
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

resource "aws_lb_listener_rule" "prd_eu_service_hacksaw_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 220

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_hacksaw_adaptor.arn
  }

  condition {
    host_header {
      values = ["api.${local.hacksaw_domain}", "apieu.${local.hacksaw_domain}"]
    }
  }

  tags = {
    Name        = "apig.${local.hacksaw_domain}"
    Environment = "sandbox"
  }
}


resource "cloudflare_record" "apihs" {
  zone_id = data.cloudflare_zone.hacksaw.id
  name    = "api"
  content = aws_lb.prd_eu.dns_name
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "prd_eu_apipgs" {
  zone_id = data.cloudflare_zone.pgs.id
  name    = "api.eu"
  content = aws_lb.prd_eu.dns_name
  type    = "CNAME"
  proxied = true
}



##############
### service-transfer-wallet
#############
module "prd_eu_service_transfer_wallet" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-transfer-wallet"

  app_name = "srv-transfer-wallet"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-transfer-wallet:v1.0.72.1"

  env = {
    "SPRING_CASSANDRA_KEYSPACE_NAME" : "prod_keyspace"
    "SPRING_CASSANDRA_CONTACT_POINTS" : "cassandra.eu-west-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY" : "local_quorum"
    "SPRING_CASSANDRA_LOCAL_DATACENTER" : "eu-west-1"
    "JAVA_OPTS" : "-Dlogging.level.com.linecorp.armeria.client.logging=DEBUG -Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dlogging.level.com.revenge.game.features.operator=DEBUG -Dsystem.logic.debug=true -Dlogging.level.com.linecorp.armeria.client.logging=DEBUG -XX:MaxDirectMemorySize=134217728 -Dfeatures.history.impl=cassandra",
    "SPRING_DATA_REDIS_URL" : "rediss://prd-eu-valkey-fe3a5n.serverless.euw1.cache.amazonaws.com:6379"
    "PORT" : "9300"
    "SERVICE_ENTITY_ADDRESS" : "https://entity.revenge-games.global"
    "SYSTEM_SIGNATURE_HOST" : "apig.rg-lgna.com"
  }

  role = aws_iam_role.prd_eu_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prd_eu_networking.vpc
    subnets = [
      module.prd_eu_networking.subnet_private_1.id,
      module.prd_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prd_eu_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prd_eu_service_transfer_wallet.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.prd_eu_service,
    aws_iam_role_policy.prd_eu_service_policy,
  ]
}

resource "aws_lb_target_group" "prd_eu_service_transfer_wallet" {
  name        = "${local.environment}-service-transfer-wallet"
  port        = 9300
  protocol    = "HTTP"
  vpc_id      = module.prd_eu_networking.vpc.id
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

resource "aws_lb_listener_rule" "prd_eu_service_transfer_wallet" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_transfer_wallet.arn
  }

  condition {
    host_header {
      values = ["apig.rg-lgna.com"]
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


##############
### service-jili-adapter
#############
module "prd_eu_service_jili_adapter" {
  providers = {
    aws = aws.current
  }

  task_size_cpu    = "2048"
  task_size_memory = "4096"

  source = "../../modules/service-jili-adapter"

  app_name = "srv-jili-adapter"
  app_env  = local.environment
  image    = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-jili-adapter:v1.0.14.1"


  env = {
    JAVA_OPTS : "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    SERVICE_GAMECLIENT_ADDRESS = "http://srv-game-client"
    WEB_CLIENT_HOST            = "https://jili.${local.root_domain}"
    SERVICE_ENTITY_ADDRESS     = "https://entity.revenge-games.global"

    SERVICE_WFGAMING_SECRET      = "ISLK5OV0V9H12W65"
    SERVICE_WFGAMING_OPERATOR_ID = "wfRGstgBRL"
    SERVICE_WFGAMING_ADDRESS     = "https://smakermicsvc.back138.com/api/opgateway/v1/op/"
    SPRING_DATA_REDIS_URL        = "rediss://prd-eu-valkey-fe3a5n.serverless.euw1.cache.amazonaws.com:6379"

    SERVICE_WFGAMING_DEBUG = "true"
    # game.client config
    SERVICE_GAMECLIENT_DEBUG = "true"
  }

  role = aws_iam_role.prd_eu_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prd_eu_networking.vpc
    subnets = [
      module.prd_eu_networking.subnet_private_1.id,
      module.prd_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prd_eu_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prd_eu_service_jili_adapter.arn,
      port = 9945
    }]
  }

  depends_on = [
    aws_iam_role.prd_eu_service,
    aws_iam_role_policy.prd_eu_service_policy,
  ]
}

resource "aws_lb_target_group" "prd_eu_service_jili_adapter" {
  name        = "${local.environment}-service-jili-adapter"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prd_eu_networking.vpc.id
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

resource "aws_lb_listener_rule" "prd_eu_service_jili_adapter" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_jili_adapter.arn
  }

  condition {
    host_header {
      values = ["jili.rg-lgna.com"]
    }
  }

  tags = {
    Name        = "jili.rg-lgna.com"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "prd_eu_service_jili_adapter" {
  zone_id = data.cloudflare_zone.root.id
  name    = "jili.eu"
  content = aws_lb.prd_eu.dns_name
  type    = "CNAME"
  proxied = true
}


##############
### service-wf-adapter
#############
module "prd_eu_service_wf_adapter" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-wf-adapter"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-wf-adapter:v1.0.7.1"

  env = {
    JAVA_OPTS                  = "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    SERVICE_GAMECLIENT_ADDRESS = "http://srv-game-client"
    WEB_CLIENT_HOST            = "https://wf.rg-lgna.com"
    SERVICE_ENTITY_ADDRESS     = "https://entity.revenge-games.global"

    SERVICE_WFGAMING_SECRET      = "ISLK5OV0V9H12W65"
    SERVICE_WFGAMING_OPERATOR_ID = "wfRGstgBRL"
    SERVICE_WFGAMING_ADDRESS     = "https://smakermicsvc.back138.com/api/opgateway/v1/op/"
    SERVICE_WFGAMING_DEBUG       = "true"
    # game.client config
    SERVICE_GAMECLIENT_DEBUG = "true"
    SPRING_DATA_REDIS_URL    = "rediss://prd-eu-valkey-fe3a5n.serverless.euw1.cache.amazonaws.com:6379"
  }

  role = aws_iam_role.prd_eu_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prd_eu_networking.vpc
    subnets = [
      module.prd_eu_networking.subnet_private_1.id,
      module.prd_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prd_eu_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prd_eu_service_wf_adapter.arn,
      port = 9900
    }]
  }

  depends_on = [
    aws_iam_role.prd_eu_service,
    aws_iam_role_policy.prd_eu_service_policy,
  ]
}

resource "aws_lb_target_group" "prd_eu_service_wf_adapter" {
  name        = "${local.environment}-srv-wf-adapter"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prd_eu_networking.vpc.id
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

resource "aws_lb_listener_rule" "prd_eu_service_wf_adapter" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 221

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_wf_adapter.arn
  }

  condition {
    host_header {
      values = ["wf.rg-lgna.com"]
    }
  }

  tags = {
    Name        = "wf.rg-lgna.com"
    Environment = "${local.environment}"
  }
}



######
# service-kinesis-consumer-report
module "prd_eu_service_kinesis_consumer_report" {
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
    "PROCESSOR_STREAM" : "prd_eu_bet_result_stream",
    "PROCESSOR_REGION" : "eu-west-1",
    "PROCESSOR_NAME" : "ReportConsumerApplication-20250708",
  }


  role = aws_iam_role.prd_eu_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prd_eu_networking.vpc
    subnets = [
      module.prd_eu_networking.subnet_private_1.id,
      module.prd_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prd_eu_networking.vpc.default_security_group_id
    ]
  }

  depends_on = [
    aws_iam_role.prd_eu_service,
    aws_iam_role_policy.prd_eu_service_policy,
  ]
}