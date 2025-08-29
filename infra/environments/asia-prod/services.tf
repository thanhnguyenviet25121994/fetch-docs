resource "aws_service_discovery_http_namespace" "prod_asia" {
  name = local.environment
}

data "aws_secretsmanager_secret" "prod_asia_service_entity_db" {
  name = "${local.environment}/service-entity/db"
}

module "prod_asia_service_entity" {
  source = "../../modules/service-entity"
  providers = {
    aws = aws.current
  }
  task_size_cpu      = 2048
  task_size_memory   = 4096
  desired_count      = 1
  instance_count_min = 1

  app_name = "service-entity"
  app_env  = local.environment
  image    = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-entity:${local.service_entity_version}"
  db = {
    endpoint    = aws_rds_cluster.prod_asia_main.endpoint
    credentials = data.aws_secretsmanager_secret.prod_asia_service_entity_db
    name        = "service_entity"
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
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_asia_service_entity_http.arn,
      port = 9500
      },
      {
        arn  = aws_lb_target_group.prod_asia_service_entity_grpc.arn,
        port = 9501
    }]
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
    aws_service_discovery_http_namespace.prod_asia,
  ]
}

resource "aws_lb_target_group" "prod_asia_service_entity_http" {
  name        = "${local.environment}-service-entity-http"
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

resource "aws_lb_listener_rule" "prod_asia_service_entity_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 600

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_entity_http.arn
  }

  condition {
    host_header {
      values = ["entity.${local.root_domain}", "bo.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "entity.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_target_group" "prod_asia_service_entity_grpc" {
  name             = "${local.environment}-service-entity-grpc"
  port             = 80
  protocol         = "HTTP"
  protocol_version = "GRPC"
  vpc_id           = module.prod_asia_networking.vpc.id
  target_type      = "ip"

  health_check {
    path                = "/AWS.ALB/healthcheck"
    healthy_threshold   = 5
    unhealthy_threshold = 10
    port                = 9501
    matcher             = "0-99"
  }

  tags = {
    Environment = local.environment
  }
}


resource "aws_lb_listener_rule" "prod_asia_service_entity_grpc" {
  listener_arn = aws_lb_listener.https_private.arn
  priority     = 600

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_entity_grpc.arn
  }

  condition {
    host_header {
      values = ["entity.revenge-games.global"]
    }
  }

  tags = {
    Name        = "entity.revenge-games.global"
    Environment = "${local.environment}"
  }
}

#temporary disable
data "aws_secretsmanager_secret" "prod_asia_service_game_client_db" {
  name = "${local.environment}/service-game-client/db"
}

module "prod_asia_service_game_client" {
  providers = {
    aws = aws.current
  }

  source                     = "../../modules/service-game-client-2"
  task_size_cpu              = 2048
  task_size_memory           = 4096
  desired_count              = 2
  instance_count_min         = 2
  deployment_maximum_percent = 150

  filter_pattern = "ERROR -\"o.s.w.reactive.socket.WebSocketHandler\" -\"Session mismatch\" -\"UNKNOWN\" -\"Missing bet setting\" -\"PlayServiceV2\" \"mahjong-fortune\" -\"bikini-babes\" -\"mermaid\" -\"run-pug-run\" -\"mochi-mochi\" -\"pandora\" -\"rave-on\" -\"samba-fiesta\" -\"sanguo\" -\"stallion-gold\" -\"sexy-christmas\""
  app_name       = "service-game-client"
  app_env        = local.environment
  image          = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-client:${local.service_game_client_version}"
  # db = {
  #   endpoint        = aws_rds_cluster.prod_asia_main.endpoint
  #   reader_endpoint = aws_rds_cluster.prod_asia_main.reader_endpoint
  #   credentials     = data.aws_secretsmanager_secret.prod_asia_service_game_client_db
  #   name            = "service_game_client"
  # }

  # opensearch = {
  #   endpoint    = module.prod_asia_opensearch.endpoint
  #   credentials = data.aws_secretsmanager_secret.prod_asia_service_game_client_db
  # }
  # env = {
  #   "MANAGEMENT_TRACING_ENABLED" : "false"
  #   "MANAGEMENT_TRACING_SAMPLING_PROBABILITY" : "0.1"
  #   "SERVICE_GAMEREPLAY_ENDPOINT" : "https://replay.${local.root_domain}/replay/"
  #   "GRPC_CLIENT_ENTITY_ADDRESS" : "static://service-entity-grpc:81"
  #   "AWS_DYNAMODB_TABLE_BETRESULTS" : "${local.environment}_bet_results"
  #   "ATTRIBUTE_DYNAMODBATTRIBUTESTABLE" : "${local.environment}_player_attributes"
  #   "AWS_DYNAMODB_TABLE_PLAYERATTRIBUTES" : "${local.environment}_player_attributes"
  # }

  env = {
    "APP_KINESIS_STREAM_NAME"                 = "prod_asia_bet_result_stream"
    "FEATURES_PLAY_LOGIC_CLIENT_VALIDATE"     = "false"
    "FEATURES_PLAY_OPERATOR_CLIENT_DEBUG"     = "false"
    "FEATURES_PROMOTION_CLIENT_URL"           = "https://promo-api.${local.rg_domain}"
    "FEATURES_REPLAY_HS"                      = "https://static.hacksawproduction.com/replay-manager"
    "FEATURES_REPLAY_HS_API"                  = "https://api.hacksawproduction.com/api"
    "FEATURES_REPLAY_PG"                      = "https://static.1adz83lbv.com"
    "FEATURES_REPLAY_PG_API"                  = "https://m.1adz83lbv.com"
    "FEATURES_REPLAY_PP"                      = "https://g.pragmaticpplay.com"
    "FEATURES_REPLAY_RC"                      = "https://uig.${local.rg_domain}"
    "FEATURES_REPLAY_RG"                      = "https://uig.${local.rg_domain}"
    "JAVA_OPTS"                               = "-Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dlogging.level.com.revenge.game.features.play=OFF -Dlogging.level.com.revenge.game.features.play.WinningReportService=INFO"
    "LOGGING_LEVEL_COM_REVENGE_GAME_API"      = "INFO"
    "MANAGEMENT_TRACING_ENABLED"              = "false"
    "MANAGEMENT_TRACING_SAMPLING_PROBABILITY" = "0.1"
    "PLAYER_ONLINE_EXPIRY"                    = "PT2H"
    "SERVER_PORT"                             = "9300"
    "SERVICE_COMMON_ASSETS_URL"               = "https://rgg.${local.rg_domain}/common-assets"
    "SERVICE_ENTITY_ADDRESS"                  = "https://entity.revenge-games.global"
    "SERVICE_GAMEREPLAY_ENDPOINT"             = "https://replay.rg-aslgna.com/replay/"
    "SERVICE_SHARED_UI_URL"                   = "https://uig.${local.rg_domain}"
    "SERVICE_WEBSOCKET_ENVURL"                = "https://apig.${local.rg_domain}"
    "SERVICE_WEBSOCKET_URL"                   = "wss://apig.${local.rg_domain}/ws"
    "SPRING_CASSANDRA_CONTACT_POINTS"         = "cassandra.ap-southeast-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_KEYSPACE_NAME"          = "prod_keyspace"
    "SPRING_CASSANDRA_LOCAL_DATACENTER"       = "ap-southeast-1"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY"    = "local_quorum"
    "SPRING_DATA_REDIS_URL"                   = "rediss://prod-asia-valkey-diqjla.serverless.apse1.cache.amazonaws.com:6379"
    "SYSTEM_DEBUG_ENABLED"                    = "false"
    "SYSTEM_LOGIC_DEBUG"                      = "false"
    "SYSTEM_LOGIC_VALIDATE"                   = "false"
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
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_asia_service_game_client.arn,
      port = 9300
    }]
  }
  services = {
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
  ]
}

##########
resource "aws_lb_target_group" "prod_asia_service_game_client" {
  name        = "${local.environment}-service-game-client"
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


resource "aws_lb_listener_rule" "env_config" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 97

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.prod_asia_service_game_client.arn
        weight = 100
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
    Name        = "env-config-testing"
    Environment = "${local.environment}"
  }
}


resource "aws_lb_listener_rule" "service_game_client_lobby" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 400

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_game_client.arn
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
    Name        = "service-game-client"
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


resource "aws_lb_listener_rule" "service_game_client_v2" {
  for_each = toset(local.game_domains)

  listener_arn = aws_lb_listener.http.arn
  priority     = 501 + index(local.game_domains, each.value)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_game_client.arn
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
        "/*"
      ]
    }
  }

  tags = {
    Name        = "service-game-client-${each.value}"
    Environment = "${local.environment}"
  }
}


resource "aws_lb_listener_rule" "service_game_client_history" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        "apig.rg-lgna.com",
        "rgg.rg-lgna.com",
        "rcg.rg-lgna.com",
        "api.rg-lgna.com"
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
    Name        = "service-game-client-history"
    Environment = "${local.environment}"
  }
}



# service-game-client-2
module "prod_asia_service_game_client_2" {
  source = "../../modules/service-game-client-new"
  providers = {
    aws = aws.current
  }

  desired_count = 0

  instance_count_min = 1
  task_size_cpu      = 2048
  task_size_memory   = 4096
  app_name           = "service-game-client-2"
  ecs_cluster_arn    = module.prod_asia_service_game_client.get_aws_ecs_cluster.arn

  app_env        = local.environment
  filter_pattern = "{ $.message = \"[ERROR]\" && $.message != \"*Error during WebSocket session*\" && $.message != \"*Handling error for session*\" }"

  image = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-client:v1.0.1735.1"

  # db = {
  #   endpoint        = aws_rds_cluster.prod_asia_main.endpoint
  #   reader_endpoint = aws_rds_cluster.prod_asia_main.reader_endpoint
  #   credentials     = data.aws_secretsmanager_secret.prod_asia_service_game_client_db
  #   name            = "service_game_client"
  # }

  env = {
    "APP_KINESIS_STREAM_NAME"                 = "prod_asia_bet_result_stream"
    "FEATURES_PLAY_LOGIC_CLIENT_VALIDATE"     = "false"
    "FEATURES_PLAY_OPERATOR_CLIENT_DEBUG"     = "false"
    "FEATURES_PROMOTION_CLIENT_URL"           = "https://promo-api.${local.rg_domain}"
    "FEATURES_REPLAY_HS"                      = "https://static.hacksawproduction.com/replay-manager"
    "FEATURES_REPLAY_HS_API"                  = "https://api.hacksawproduction.com/api"
    "FEATURES_REPLAY_PG"                      = "https://static.1adz83lbv.com"
    "FEATURES_REPLAY_PG_API"                  = "https://m.1adz83lbv.com"
    "FEATURES_REPLAY_PP"                      = "https://g.pragmaticpplay.com"
    "FEATURES_REPLAY_RC"                      = "https://uig.${local.rg_domain}"
    "FEATURES_REPLAY_RG"                      = "https://uig.${local.rg_domain}"
    "JAVA_OPTS"                               = "-Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dlogging.level.com.revenge.game.features.play=OFF -Dlogging.level.com.revenge.game.features.play.WinningReportService=INFO"
    "LOGGING_LEVEL_COM_REVENGE_GAME_API"      = "INFO"
    "MANAGEMENT_TRACING_ENABLED"              = "false"
    "MANAGEMENT_TRACING_SAMPLING_PROBABILITY" = "0.1"
    "PLAYER_ONLINE_EXPIRY"                    = "PT2H"
    "SERVER_PORT"                             = "9300"
    "SERVICE_COMMON_ASSETS_URL"               = "https://rgg.${local.rg_domain}/common-assets"
    "SERVICE_ENTITY_ADDRESS"                  = "https://entity.revenge-games.global"
    "SERVICE_GAMEREPLAY_ENDPOINT"             = "https://replay.rg-aslgna.com/replay/"
    "SERVICE_SHARED_UI_URL"                   = "https://uig.${local.rg_domain}"
    "SERVICE_WEBSOCKET_ENVURL"                = "https://apig.${local.rg_domain}"
    "SERVICE_WEBSOCKET_URL"                   = "wss://apig.${local.rg_domain}/ws"
    "SPRING_CASSANDRA_CONTACT_POINTS"         = "cassandra.ap-southeast-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_KEYSPACE_NAME"          = "prod_keyspace"
    "SPRING_CASSANDRA_LOCAL_DATACENTER"       = "ap-southeast-1"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY"    = "local_quorum"
    "SPRING_DATA_REDIS_URL"                   = "rediss://prod-asia-valkey-diqjla.serverless.apse1.cache.amazonaws.com:6379"
    "SPRING.CODEC.MAX-IN-MEMORY-SIZE"         = "20MB"
    "SYSTEM_DEBUG_ENABLED"                    = "false"
    "SYSTEM_LOGIC_DEBUG"                      = "false"
    "SYSTEM_LOGIC_VALIDATE"                   = "false"
  }

  role = aws_iam_role.prod_asia_service
  network_configuration = {
    region = local.region
    vpc    = module.prod_asia_networking.vpc
    subnets = [
      module.prod_asia_networking.subnet_private_1.id,
      module.prod_asia_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prod_asia_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_asia_service_game_client_2.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_asia_service_game_client_2" {
  name        = "${local.environment}-service-game-client-2"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_asia_networking.vpc.id
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

resource "aws_lb_listener_rule" "prod_asia_service_game_client_2" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_game_client_2.arn
  }

  condition {
    host_header {
      values = ["api.${local.root_domain}"]
    }
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  tags = {
    Name        = "api.${local.root_domain}"
    Environment = "${local.environment}"
  }
}



###mTLS
resource "aws_lb_listener_rule" "tw_cert" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 9200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_transfer_wallet.arn
  }

  condition {
    host_header {
      values = [
        "12da286799.rg-lgna.com"
      ]
    }
  }

  condition {
    path_pattern {
      values = [
        "/api/v1/transfer/*"
      ]
    }
  }

  tags = {
    Name        = "tw-cert"
    Environment = "${local.environment}"
  }
}
resource "aws_lb_listener_rule" "sgc_cert" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 9300

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        "12da286799.rg-lgna.com"
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
    Name        = "sgc-cert"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "api_sgc" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 330

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        "api.rg-aslgna.com",
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
    Name        = "service-game-client"
    Environment = "${local.environment}"
  }
}


resource "aws_lb_listener_rule" "service_game_client_asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        "asg.rg-lgna.com"
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

resource "aws_lb_listener_rule" "service_game_client_ws" {
  for_each = toset(local.game_domains)

  listener_arn = aws_lb_listener.http.arn
  priority     = 301 + index(local.game_domains, each.value)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_game_client.arn
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
    Name        = "service-game-client-ws-${each.value}"
    Environment = "${local.environment}"
  }
}



resource "cloudflare_record" "prod_asia_api" {
  zone_id = data.cloudflare_zone.root.id
  name    = "api"
  content = aws_lb.prod_asia.dns_name
  type    = "CNAME"
  proxied = true
}



##############
### service-pp-adaptor
#############
module "prod_asia_service_pp_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-pp-adaptor"

  app_name = "service-pp-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-pp-adaptor:v1.0.290.1"

  env = {
    SERVICE_CLIENT = "https://apig.${local.rg_domain}"
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
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_asia_service_pp_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_asia_service_pp_adaptor" {
  name        = "${local.environment}-service-pp-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_asia_networking.vpc.id
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

resource "aws_lb_listener_rule" "prod_asia_service_pp_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 209

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_pp_adaptor.arn
  }

  condition {
    host_header {
      values = ["apig.${local.pp_domain}", "g.${local.pp_domain}"]
    }
  }

  tags = {
    Name        = "apig.${local.pp_domain}"
    Environment = "${local.environment}"
  }
}




##############
### service-pgs-adaptor
#############
module "prod_asia_service_pgs_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-pgs-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-pgs-adaptor:v1.0.55.1"

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
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_asia_service_pgs_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_asia_service_pgs_adaptor" {
  name        = "${local.environment}-service-pgs-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_asia_networking.vpc.id
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

resource "aws_lb_listener_rule" "prod_asia_service_pgs_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 190

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_pgs_adaptor.arn
  }

  condition {
    host_header {
      values = ["apipgs.${local.root_domain}", "api.${local.pgs_domain}"]
    }
  }

  tags = {
    Name        = "${local.root_domain}"
    Environment = "${local.environment}"
  }
}



##############
### service-hacksaw-adaptor
#############
module "prod_asia_service_hacksaw_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-hacksaw-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-hacksaw-adaptor:v1.0.39.1"


  env = {
    LOG_LEVEL                      = "error"
    NODE_ENV                       = "production"
    SGC_HOST                       = "http://service-game-client"
    SERVICE_CLIENT_REQUEST_TIMEOUT = "10000"
    GAME_CODE_PREFIX               = "hs-"
    API_HOST                       = "https://api.${local.hacksaw_domain}"
    STATIC_HOST                    = "https://static.${local.hacksaw_domain}"
    PORT                           = "8080"
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
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_asia_service_hacksaw_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_asia_service_hacksaw_adaptor" {
  name        = "${local.environment}-service-hs-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_asia_networking.vpc.id
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

resource "aws_lb_listener_rule" "prod_asia_service_hacksaw_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 220

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_hacksaw_adaptor.arn
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
### service-transfer-wallet
#############
module "prod_asia_service_transfer_wallet" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-transfer-wallet"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-transfer-wallet:v1.0.72.1"

  env = {
    "SPRING_CASSANDRA_KEYSPACE_NAME" : "prod_keyspace"
    "SPRING_CASSANDRA_CONTACT_POINTS" : "cassandra.ap-southeast-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY" : "local_quorum"
    "SPRING_CASSANDRA_LOCAL_DATACENTER" : "ap-southeast-1"
    "JAVA_OPTS" : "-Dlogging.level.com.linecorp.armeria.client.logging=ERROR -Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dlogging.level.com.revenge.game.features.operator=ERROR -Dsystem.logic.debug=false -XX:MaxDirectMemorySize=134217728",
    "SPRING_DATA_REDIS_URL" : "rediss://prod-asia-valkey-diqjla.serverless.apse1.cache.amazonaws.com:6379"
    "PORT" : "9300"
    "SERVICE_ENTITY_ADDRESS" : "https://entity.revenge-games.global"
    "LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_DATA_CASSANDRA" : false
    "LOGGING_LEVEL_ROOT" : "ERROR"
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
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_asia_service_transfer_wallet.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_asia_service_transfer_wallet" {
  name        = "${local.environment}-service-tw"
  port        = 9300
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

resource "aws_lb_listener_rule" "prod_asia_service_transfer_wallet" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_transfer_wallet.arn
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
module "prod_asia_service_jili_adapter" {
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
    SPRING_DATA_REDIS_URL        = "rediss://prod-asia-valkey-diqjla.serverless.apse1.cache.amazonaws.com:6379"

    SERVICE_WFGAMING_DEBUG = "true"
    # game.client config
    SERVICE_GAMECLIENT_DEBUG = "true"
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
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_asia_service_jili_adapter.arn,
      port = 9945
    }]
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_asia_service_jili_adapter" {
  name        = "${local.environment}-service-jili-adapter"
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

resource "aws_lb_listener_rule" "prod_asia_service_jili_adapter" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_jili_adapter.arn
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

resource "cloudflare_record" "prod_asia_service_jili_adapter" {
  zone_id = data.cloudflare_zone.root.id
  name    = "jili"
  content = aws_lb.prod_asia.dns_name
  type    = "CNAME"
  proxied = true
}



##############
### service-wf-adapter
#############
module "prod_asia_service_wf_adapter" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-wf-adapter"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-wf-adapter:v1.0.7.1"

  env = {
    JAVA_OPTS                  = "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    SERVICE_GAMECLIENT_ADDRESS = "http://service-game-client"
    WEB_CLIENT_HOST            = "https://wf.rg-lgna.com"
    SERVICE_ENTITY_ADDRESS     = "https://entity.revenge-games.global"

    SERVICE_WFGAMING_SECRET      = "ISLK5OV0V9H12W65"
    SERVICE_WFGAMING_OPERATOR_ID = "wfRGstgBRL"
    SERVICE_WFGAMING_ADDRESS     = "https://smakermicsvc.back138.com/api/opgateway/v1/op/"
    SERVICE_WFGAMING_DEBUG       = "true"
    # game.client config
    SERVICE_GAMECLIENT_DEBUG = "true"
    SPRING_DATA_REDIS_URL    = "rediss://prod-asia-valkey-diqjla.serverless.apse1.cache.amazonaws.com:6379"
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
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_asia_service_wf_adapter.arn,
      port = 9900
    }]
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_asia_service_wf_adapter" {
  name        = "${local.environment}-service-wf-adapter"
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

resource "aws_lb_listener_rule" "prod_asia_service_wf_adapter" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 221

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_wf_adapter.arn
  }

  condition {
    host_header {
      values = ["wf.rg-lgna.com"]
    }
  }

  tags = {
    Name        = "wf.${local.root_domain}"
    Environment = "${local.environment}"
  }
}




##############
### service-promotion
#############

data "aws_secretsmanager_secret" "prod_asia_service_promotion" {
  name = "${local.environment}/service-promotion/env"
}
module "prod_asia_service_promotion" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-promotion"

  task_size_cpu    = "2048"
  task_size_memory = "4096"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-promotion:v1.0.250.1"


  env = {
    "JAVA_OPTS" : "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    "FEATURES_PROMOTION_CLIENT_URL" : "https://promo-api.rg-lgna.com",
    "SERVICE_ENTITY_ADDRESS" : "http://service-entity"
    "SPRING_DATA_REDIS_URL" : "rediss://prod-asia-valkey-diqjla.serverless.apse1.cache.amazonaws.com:6379"
    "SYSTEM_SIGNATURE_HOST" : "promo-api.rg-lgna.com"
    "LOG_LEVEL" : "error"
  }

  secrets = {
    credentials = data.aws_secretsmanager_secret.prod_asia_service_promotion
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
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_asia_service_promotion.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_asia_service_promotion" {
  name        = "${local.environment}-service-promotion"
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

resource "aws_lb_listener_rule" "prod_asia_service_promotion" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 2031

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_promotion.arn
  }

  condition {
    host_header {
      values = ["promo-api.rg-lgna.com"]
    }
  }

  tags = {
    Name        = "service-promotion"
    Environment = "${local.environment}"
  }
}
resource "cloudflare_record" "service_promotion" {
  zone_id = data.cloudflare_zone.rg.id
  name    = "promo-api"
  value   = aws_lb.prod_asia.dns_name
  type    = "CNAME"
  proxied = true
}



######
# service-kinesis-consumer-report
module "prod_asia_service_kinesis_consumer_report" {
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
    "PROCESSOR_STREAM" : "prod_asia_bet_result_stream",
    "PROCESSOR_REGION" : "ap-southeast-1",
    "PROCESSOR_NAME" : "ReportConsumerApplication-20250708",
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
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
  ]
}