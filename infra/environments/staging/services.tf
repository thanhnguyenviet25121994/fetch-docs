resource "aws_service_discovery_http_namespace" "staging" {
  name = local.environment
}

data "aws_secretsmanager_secret" "staging_service_entity_db" {
  name = "${local.environment}/service-entity/db"
}

module "staging_service_entity" {
  source = "../../modules/service-entity"
  providers = {
    aws = aws.current
  }
  task_size_cpu    = 2048
  task_size_memory = 4096

  desired_count = 1

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-entity:${local.service_entity_version}"
  db = {
    endpoint    = aws_rds_cluster.staging_main.endpoint
    credentials = data.aws_secretsmanager_secret.staging_service_entity_db
    name        = "service_entity"
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
      arn  = aws_lb_target_group.staging_service_entity_http.arn,
      port = 9500
    }]
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}

resource "aws_lb_target_group" "staging_service_entity_http" {
  name        = "${local.environment}-service-entity-http"
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

resource "aws_lb_listener_rule" "staging_service_entity_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 600

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_entity_http.arn
  }

  condition {
    host_header {
      values = ["entity.${local.environment}.${local.root_domain}", "bo.sandbox.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "entity.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

data "aws_secretsmanager_secret" "staging_service_game_client_db" {
  name = "${local.environment}/service-game-client/db"
}

module "staging_service_game_client" {
  providers = {
    aws = aws.current
  }

  source           = "../../modules/service-game-client"
  task_size_cpu    = 2048
  task_size_memory = 4096
  desired_count    = 1

  filter_pattern = "[ERROR]"
  app_env        = local.environment
  image          = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-client:${local.service_game_client_version}"
  db = {
    endpoint        = aws_rds_cluster.staging_main.endpoint
    reader_endpoint = aws_rds_cluster.staging_main.reader_endpoint
    credentials     = data.aws_secretsmanager_secret.staging_service_game_client_db
    name            = "service_game_client"
  }

  # opensearch = {
  #   endpoint    = module.staging_opensearch_2.endpoint
  #   credentials = data.aws_secretsmanager_secret.staging_service_game_client_db
  # }
  env = {
    "APP_KINESIS_STREAM_NAME" : "staging_bet_result_stream"
    "FEATURES_PLAY_LOGIC_CLIENT_DEBUG" : false
    "FEATURES_PLAY_OPERATOR_CLIENT_DEBUG" : false
    "FEATURES_PROMOTION_CLIENT_URL" : "https://promotion.sandbox.revenge-games.com"
    "FEATURES_REPLAY_HS" : "https://static.hacksaw.sandbox.${local.root_domain}"
    "FEATURES_REPLAY_HS_API" : "https://api.hacksaw.sandbox.${local.root_domain}"
    "FEATURES_REPLAY_PG" : "https://static.pgs.sandbox.${local.root_domain}"
    "FEATURES_REPLAY_PG_API" : "https:/m.pgs.sandbox.${local.root_domain}"
    "FEATURES_REPLAY_PP" : "https://sandbox.pragmaticpplay.com"
    "FEATURES_REPLAY_RC" : "https://share-ui-game-client.sandbox.${local.root_domain}"
    "FEATURES_REPLAY_RG" : "https://replay.staging.${local.root_domain}/replay/"
    "JAVA_OPTS" : "-Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dlogging.level.com.linecorp.armeria.client.logging=DEBUG -XX:MaxDirectMemorySize=134217728"
    "PLAYER_ONLINE_EXPIRY" : "PT2H"
    "SERVER_PORT" : 9300
    "SERVICE_COMMON_ASSETS_URL" : "https://common-assets.sandbox.${local.root_domain}"
    "SERVICE_ENTITY_ADDRESS" : "http://service-entity-grpc:81"
    "SERVICE_GAMEREPLAY_ENDPOINT" : "https://replay.${local.environment}.revenge-games.com/replay/"
    "SERVICE_SHARED_UI_URL" : "https://share-ui-game-client.sandbox.${local.root_domain}"
    "SYSTEM_DEBUG_ENABLED" : "true"
    "SERVICE_WEBSOCKET_ENVURL" : "https://api.sandbox.${local.root_domain}"
    "SERVICE_WEBSOCKET_URL" : "wss://api.sandbox.${local.root_domain}/ws"
    "SPRING_CASSANDRA_CONTACT_POINTS" : "cassandra.ap-northeast-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_KEYSPACE_NAME" : "staging_keyspace"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY" : "local_quorum"
    "SPRING_DATA_REDIS_URL" : "rediss://staging-valkey-nnlcn8.serverless.apne1.cache.amazonaws.com:6379"
    "SYSTEM_LOGIC_VALIDATE" : "true"
    "SYSTEM_LOGIC_DEBUG" : "true"
    "SPRING_CASSANDRA_LOCAL_DATACENTER" : "ap-northeast-1"
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
      arn  = aws_lb_target_group.staging_service_game_client.arn,
      port = 9300
    }]
  }
  services = {
    # service-game-client-dashboard = {
    #   env = {
    #     "SERVICE_GAMEREPLAY_ENDPOINT" : "https://replay.${local.environment}.revenge-games.com/replay/"
    #     "GRPC_CLIENT_ENTITY_ADDRESS" : "static://service-entity-grpc:81"
    #     "AWS_DYNAMODB_TABLE_BETRESULTS" : "staging_bet_results"
    #     "ATTRIBUTE_DYNAMODBATTRIBUTESTABLE" : "staging_player_attributes"
    #     "AWS_DYNAMODB_TABLE_PLAYERATTRIBUTES" : "staging_player_attributes"
    #     "SYSTEM_DEBUG_ENABLED" : "true"
    #     "ORG_JOBRUNR_DASHBOARD_ENABLED" : "true"
    #     "ORG_JOBRUNR_BACKGROUND_JOB_SERVER_ENABLED" : "false"
    #     "ORG_JOBRUNR_DASHBOARD_PORT" : 9301
    #   }
    #   lb = {
    #     arn  = aws_lb_target_group.staging_service_game_client_dashboard.arn,
    #     port = 9301
    #   }
    # },
    # service-game-client-worker = {
    #   env = {
    #     "SERVICE_GAMEREPLAY_ENDPOINT" : "https://replay.${local.environment}.revenge-games.com/replay/"
    #     "GRPC_CLIENT_ENTITY_ADDRESS" : "static://service-entity-grpc:81"
    #     "AWS_DYNAMODB_TABLE_BETRESULTS" : "staging_bet_results"
    #     "ATTRIBUTE_DYNAMODBATTRIBUTESTABLE" : "staging_player_attributes"
    #     "AWS_DYNAMODB_TABLE_PLAYERATTRIBUTES" : "staging_player_attributes"

    #     "SYSTEM_DEBUG_ENABLED" : "true"
    #     "ORG_JOBRUNR_DASHBOARD_ENABLED" : "false"
    #     "ORG_JOBRUNR_BACKGROUND_JOB_SERVER_ENABLED" : "true"
    #   }
    #   lb = {

    #   }
    # },
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}
###### staging dashboard retry new
resource "aws_lb_target_group" "staging_service_game_client_dashboard" {
  name        = "${local.environment}-service-game-client-dash"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.staging_networking.vpc.id
  target_type = "ip"

  health_check {
    path                = "/dashboard"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  tags = {
    Environment = local.environment
  }
}

resource "aws_lb_listener_rule" "staging_service_game_client_dashboard" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 207

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_game_client_dashboard.arn
  }

  condition {
    host_header {
      values = ["retry.${local.environment}.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "retry.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}
##########
resource "aws_lb_target_group" "staging_service_game_client" {
  name        = "${local.environment}-service-game-client"
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

resource "aws_lb_listener_rule" "staging_service_game_client" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_game_client.arn
  }

  condition {
    host_header {
      values = ["api.sandbox.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "api.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}


locals {
  game_domains = [
    "g.sandbox.all-star.games",
    "g.sandbox.rectangle-games.com",
    "g.sandbox.revenge-games.com",
  ]
}

resource "aws_lb_listener_rule" "staging_service_game_client_2" {
  for_each = toset(local.game_domains)

  listener_arn = aws_lb_listener.http.arn
  priority     = 201 + index(local.game_domains, each.value)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_game_client.arn
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
        "/*/spin",
      ]
    }
  }

  tags = {
    Name        = "srv-game-client-${index(local.game_domains, each.value)}"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "env_config" {
  for_each = toset(local.game_domains)

  listener_arn = aws_lb_listener.http.arn
  priority     = 80 + index(local.game_domains, each.value)

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.staging_service_game_client.arn
      }
      stickiness {
        enabled  = false
        duration = 3600
      }
    }
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
      values = ["/api/v1/client/*/env-config.*.js", "/api/v1/client/*/env-config.js"]
    }
  }

  tags = {
    Name        = "env-config${index(local.game_domains, each.value)}"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "staging_service_game_client_3" {
  for_each = toset(local.game_domains)

  listener_arn = aws_lb_listener.http.arn
  priority     = 231 + index(local.game_domains, each.value)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_game_client.arn
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



resource "cloudflare_record" "staging_retry_dashboard" {
  zone_id = data.cloudflare_zone.root.id
  name    = "retry.${local.environment}.${local.root_domain}"
  value   = aws_lb.staging.dns_name
  type    = "CNAME"
  proxied = true
}

resource "aws_lb_listener_rule" "staging_lobby" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 48000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_game_client.arn
  }

  condition {
    host_header {
      values = ["lobby.*"]
    }
  }
  tags = {
    Name        = "lobby.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}


resource "aws_lb_listener_rule" "alias_lobby" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 48001

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_game_client.arn
  }

  condition {
    host_header {
      values = ["${local.pxplaygaming_domain}"]
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
    Name        = "${local.pxplaygaming_domain}"
    Environment = "${local.environment}"
  }
}

# module "staging_opensearch_2" {
#   source = "../../modules/service-opensearch"
#   providers = {
#     aws = aws.current
#   }

#   app_name = "opensearch-2"

#   app_env       = local.environment
#   region        = local.region
#   instance_type = "m7g.medium.search"
#   network_configuration = {
#     vpc = module.staging_networking.vpc
#     subnet_ids = [
#       module.staging_networking.subnet_private_1.id
#     ]
#   }
# }

resource "cloudflare_record" "staging_api" {
  zone_id = data.cloudflare_zone.root.id
  name    = "api.sandbox.revenge-games.com"
  value   = aws_lb.staging.dns_name
  type    = "CNAME"
  proxied = true
}




#########################
#### service marketing 2
#########################
data "aws_secretsmanager_secret" "staging_service_marketing_2" {
  name = "${local.environment}/service-marketing-2/env"
}
module "staging_service_marketing_2" {
  providers = {
    aws = aws.current
  }
  instance_count_min = 1
  source             = "../../modules/service-marketing-2"

  task_size_cpu    = 2048
  task_size_memory = 4096

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-marketing-2:v1.0.121.1"


  secrets = {
    credentials = data.aws_secretsmanager_secret.staging_service_marketing_2
  }

  env = {
    SPRING_DATA_REDIS_URL  = "rediss://staging-valkey-nnlcn8.serverless.apne1.cache.amazonaws.com:6379",
    SERVICE_ENTITY_ADDRESS = "http://service-entity-grpc:81",
    JAVA_OPTS              = "-Dlogging.level.org.slf4j=DEBUG"

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
      arn  = aws_lb_target_group.staging_service_marketing_2.arn,
      port = 9600
    }]
  }

}

resource "aws_lb_target_group" "staging_service_marketing_2" {
  name        = "${local.environment}-service-marketing-2"
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

resource "aws_lb_listener_rule" "staging_service_marketing_2" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 210

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_marketing_2.arn
  }

  condition {
    host_header {
      values = ["studio.sandbox.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "studio.sandbox.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

##############
### service-pp-adaptor
#############
module "staging_service_pp_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-pp-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-pp-adaptor:v1.0.308.1"

  env = {
    LOBBY_URL      = "https://lobby.sandbox.pragmaticpplay.com",
    SERVICE_CLIENT = "https://api.sandbox.revenge-games.com",
    VS_VERSION     = "v1"
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
      arn  = aws_lb_target_group.staging_service_pp_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}

resource "aws_lb_target_group" "staging_service_pp_adaptor" {
  name        = "${local.environment}-service-pp-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.staging_networking.vpc.id
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

resource "aws_lb_listener_rule" "staging_service_pp_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 209

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_pp_adaptor.arn
  }

  condition {
    host_header {
      values = ["sbox.pragmaticpplay.com", "sandbox.pragmaticpplay.com"]
    }
  }

  tags = {
    Name        = "pp.sandbox.${local.root_domain}"
    Environment = "${local.environment}"
  }
}




################
### Metabase
################
data "aws_secretsmanager_secret" "staging_service_metabase_db" {
  name = "${local.environment}/service-metabase/mb"
}

module "staging_service_metabase" {
  source = "../../modules/service-metabase"
  providers = {
    aws = aws.current
  }

  cluster_arn = module.staging_service_game_client.get_aws_ecs_cluster.arn

  instance_count_min = 1

  app_env = local.environment
  image   = "211125478834.dkr.ecr.ap-northeast-1.amazonaws.com/revengegames/metabase-clickhouse:v0.53.1"
  db = {
    endpoint    = aws_rds_cluster.staging_main.endpoint
    credentials = data.aws_secretsmanager_secret.staging_service_metabase_db
    name        = "service_metabase"
  }

  env = {
  }

  role = aws_iam_role.staging_service
  network_configuration = {
    region = local.region
    vpc    = module.staging_networking.vpc
    subnets = [
      module.staging_networking.subnet_private_1.id,
      module.staging_networking.subnet_private_2.id
    ]
    security_groups = [
      module.staging_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.staging_service_metabase.arn,
      port = 3000
    }]
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}
resource "aws_lb_target_group" "staging_service_metabase" {
  name        = "${local.environment}-service-metabase"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.staging_networking.vpc.id
  target_type = "ip"

  health_check {
    path                = "/api/health"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  tags = {
    Environment = local.environment
  }
}

resource "aws_lb_listener_rule" "staging_service_metabase" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 700

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_metabase.arn
  }

  condition {
    host_header {
      values = ["mb.sandbox.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "mb.sandbox.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "staging_metabase" {
  zone_id = data.cloudflare_zone.root.id
  name    = "mb.sandbox.${local.root_domain}"
  value   = aws_lb.staging.dns_name
  type    = "CNAME"
  proxied = true
}



##############
### service-pgs-adaptor
#############
module "staging_service_pgs_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-pgs-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-pgs-adaptor:v1.0.25.1"

  env = {
    SGC_HOST            = "https://api.sandbox.revenge-games.com",
    API_HOST            = "https://api.pgs.sandbox.revenge-games.com",
    DISABLE_CACHE       = "true"
    M_HOST              = "https://m.pgs.sandbox.revenge-games.com"
    STATIC_HOST         = "https://static.pgs.sandbox.revenge-games.com"
    SGC_REQUEST_TIMEOUT = 10000
    GAME_CODE_PREFIX    = "pgs-"
    ERROR_MESSAGE       = "true"
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
      arn  = aws_lb_target_group.staging_service_pgs_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}

resource "aws_lb_target_group" "staging_service_pgs_adaptor" {
  name        = "${local.environment}-service-pgs-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.staging_networking.vpc.id
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

resource "aws_lb_listener_rule" "staging_service_pgs_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 190

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_pgs_adaptor.arn
  }

  condition {
    host_header {
      values = ["api.pgs.sandbox.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "pgs.sandbox.${local.root_domain}"
    Environment = "${local.environment}"
  }
}



##############
### service-hacksaw-adaptor
#############
module "staging_service_hacksaw_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-hacksaw-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-hacksaw-adaptor:v1.0.7.1"


  env = {
    LOG_LEVEL                      = "debug"
    NODE_ENV                       = "development"
    SGC_HOST                       = "http://service-game-client"
    SERVICE_CLIENT_REQUEST_TIMEOUT = "10000"
    GAME_CODE_PREFIX               = "hs-"
    API_HOST                       = "https://api.hacksaw.sandbox.revenge-games.com"
    STATIC_HOST                    = "https://static.hacksaw.sandbox.revenge-games.com"
    PORT                           = "8080"
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
      arn  = aws_lb_target_group.staging_service_hacksaw_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}

resource "aws_lb_target_group" "staging_service_hacksaw_adaptor" {
  name        = "${local.environment}-service-hacksaw-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.staging_networking.vpc.id
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

resource "aws_lb_listener_rule" "staging_service_hacksaw_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 220

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_hacksaw_adaptor.arn
  }

  condition {
    host_header {
      values = ["api.hacksaw.sandbox.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "hacksaw.sandbox.${local.root_domain}"
    Environment = "sandbox"
  }
}

##############
### service-transfer-wallet
#############
module "staging_service_transfer_wallet" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-transfer-wallet"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-transfer-wallet:v1.0.29.1"

  env = {
    "SPRING_CASSANDRA_KEYSPACE_NAME" : "staging_keyspace"
    "SPRING_CASSANDRA_CONTACT_POINTS" : "cassandra.ap-northeast-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY" : "local_quorum"
    "SPRING_CASSANDRA_LOCAL_DATACENTER" : "ap-northeast-1"
    "JAVA_OPTS" : "-Dlogging.level.com.linecorp.armeria.client.logging=DEBUG -Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dlogging.level.com.revenge.game.features.operator=DEBUG -Dsystem.logic.debug=true -Dlogging.level.com.linecorp.armeria.client.logging=DEBUG -XX:MaxDirectMemorySize=134217728 -Dfeatures.history.impl=cassandra -Dspring.cassandra.keyspace-name=staging_keyspace -Dspring.cassandra.contact-points=cassandra.ap-northeast-1.amazonaws.com:9142 -Dspring.cassandra.request.consistency=local_quorum -Dspring.cassandra.local-datacenter=ap-northeast-1",
    "SYSTEM_LOGIC_VALIDATE" : "true"
    "SPRING_DATA_REDIS_URL" : "rediss://staging-valkey-nnlcn8.serverless.apne1.cache.amazonaws.com:6379"
    "PORT" : "9300"
    "SERVER_PORT" : 9300
    "SERVICE_ENTITY_ADDRESS" : "http://service-entity-grpc:81"
    "SYSTEM_SIGNATURE_HOST" : "api.sandbox.revenge-games.com"
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
      arn  = aws_lb_target_group.staging_service_transfer_wallet.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}

resource "aws_lb_target_group" "staging_service_transfer_wallet" {
  name        = "${local.environment}-service-transfer-wallet"
  port        = 9300
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

resource "aws_lb_listener_rule" "staging_service_transfer_wallet" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 90

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_transfer_wallet.arn
  }

  condition {
    host_header {
      values = ["api.sandbox.${local.root_domain}", "tw.sandbox.${local.root_domain}"]
    }
  }
  condition {
    path_pattern {
      values = [
        "/api/v1/transfer/*",
      ]
    }
  }

  tags = {
    Name        = "tw.sandbox.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "staging_service_transfer_wallet" {
  zone_id = data.cloudflare_zone.root.id
  name    = "tw.sandbox"
  content = aws_lb.staging.dns_name
  type    = "CNAME"
  proxied = true
}



##############
### service-wf-adapter
#############
module "staging_service_wf_adapter" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-wf-adapter"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-wf-adapter:v1.0.6.1"

  env = {
    JAVA_OPTS : "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    SERVICE_GAMECLIENT_ADDRESS = "https://api.sandbox.revenge-games.com"
    WEB_CLIENT_HOST            = "https://callbacks.sandbox.revenge-games.com"
    SERVICE_ENTITY_ADDRESS     = "http://service-entity-grpc:81"

    SERVICE_WFGAMING_SECRET      = "ISLK5OV0V9H12W65"
    SERVICE_WFGAMING_OPERATOR_ID = "wfRGstgBRL"
    SERVICE_WFGAMING_ADDRESS     = "https://smakermicsvc.back138.com/api/opgateway/v1/op/"
    SPRING_DATA_REDIS_URL        = "rediss://staging-valkey-nnlcn8.serverless.apne1.cache.amazonaws.com:6379"

    SERVICE_WFGAMING_DEBUG = "true"
    # game.client config
    SERVICE_GAMECLIENT_DEBUG = "true"
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
      arn  = aws_lb_target_group.staging_service_wf_adapter.arn,
      port = 9900
    }]
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}

resource "aws_lb_target_group" "staging_service_wf_adapter" {
  name        = "${local.environment}-service-wf-adapter"
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

resource "aws_lb_listener_rule" "staging_service_wf_adapter" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 221

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_wf_adapter.arn
  }

  condition {
    host_header {
      values = ["callbacks.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "callbacks.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "staging_service_wf_adapter" {
  zone_id = data.cloudflare_zone.root.id
  name    = "callbacks"
  content = aws_lb.staging.dns_name
  type    = "CNAME"
  proxied = true
}



##############
### service-leaderboard
#############
module "staging_service_leaderboard" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-leaderboard"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-leaderboard:v1.0.3.1"

  env = {
    "JAVA_OPTS" : "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    "GRPC_CLIENT_ENTITY_ADDRESS" : "http://service-entity-grpc:81",
    "SPRING_CASSANDRA_KEYSPACE_NAME" : "staging_keyspace"
    "SPRING_CASSANDRA_CONTACT_POINTS" : "cassandra.ap-northeast-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY" : "local_quorum"
    "SPRING_CASSANDRA_LOCAL_DATACENTER" : "ap-northeast-1"
    "SPRING_CASSANDRA_SCHEMA_ACTION" : "CREATE_IF_NOT_EXISTS"
    "SPRING_DATA_REDIS_URL" : "rediss://staging-valkey-nnlcn8.serverless.apne1.cache.amazonaws.com:6379"
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
      arn  = aws_lb_target_group.staging_service_leaderboard.arn,
      port = 9760
    }]
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}

resource "aws_lb_target_group" "staging_service_leaderboard" {
  name        = "${local.environment}-service-leaderboard"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.staging_networking.vpc.id
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

resource "aws_lb_listener_rule" "staging_service_leaderboard" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 2030

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_leaderboard.arn
  }

  condition {
    host_header {
      values = ["leaderboard.${local.environment}.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "service-leaderboard"
    Environment = "${local.environment}"
  }
}
resource "cloudflare_record" "service_leaderboard" {
  zone_id = data.cloudflare_zone.root.id
  name    = "leaderboard.sandbox"
  value   = aws_lb.staging.dns_name
  type    = "CNAME"
  proxied = true
}



##############
### service-jili-adapter
#############
module "staging_service_jili_adapter" {
  providers = {
    aws = aws.current
  }

  task_size_cpu    = "2048"
  task_size_memory = "4096"

  source = "../../modules/service-jili-adapter"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-jili-adapter:v1.0.3.1"


  env = {
    JAVA_OPTS : "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    SERVICE_GAMECLIENT_ADDRESS = "https://api.sandbox.revenge-games.com"
    WEB_CLIENT_HOST            = "https://jilicallbacks.revenge-games.com"
    SERVICE_ENTITY_ADDRESS     = "http://service-entity-grpc:81"

    SERVICE_WFGAMING_SECRET      = "ISLK5OV0V9H12W65"
    SERVICE_WFGAMING_OPERATOR_ID = "wfRGstgBRL"
    SERVICE_WFGAMING_ADDRESS     = "https://smakermicsvc.back138.com/api/opgateway/v1/op/"
    SPRING_DATA_REDIS_URL        = "rediss://staging-valkey-nnlcn8.serverless.apne1.cache.amazonaws.com:6379"

    SERVICE_WFGAMING_DEBUG = "true"
    # game.client config
    SERVICE_GAMECLIENT_DEBUG = "true"
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
      arn  = aws_lb_target_group.staging_service_jili_adapter.arn,
      port = 9945
    }]
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}

resource "aws_lb_target_group" "staging_service_jili_adapter" {
  name        = "${local.environment}-service-jili-adapter"
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

resource "aws_lb_listener_rule" "staging_service_jili_adapter" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_jili_adapter.arn
  }

  condition {
    host_header {
      values = ["jilicallback.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "jilicallback.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "staging_service_jili_adapter" {
  zone_id = data.cloudflare_zone.root.id
  name    = "jilicallback"
  content = aws_lb.staging.dns_name
  type    = "CNAME"
  proxied = true
}




##############
### service-promotion
#############

data "aws_secretsmanager_secret" "staging_service_promotion" {
  name = "${local.environment}/service-promotion/env"
}
module "staging_service_promotion" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-promotion"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-promotion:v1.0.247.1"


  env = {
    "JAVA_OPTS" : "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    "FEATURES_PROMOTION_CLIENT_URL" : "https://promotion.sandbox.revenge-games.com",
    "SERVICE_ENTITY_ADDRESS" : "http://service-entity-grpc:81"
    "SPRING_DATA_REDIS_URL" : "rediss://staging-valkey-nnlcn8.serverless.apne1.cache.amazonaws.com:6379"
    "SYSTEM_SIGNATURE_HOST" : "promotion.sandbox.revenge-games.com"
  }

  secrets = {
    credentials = data.aws_secretsmanager_secret.staging_service_promotion
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
      arn  = aws_lb_target_group.staging_service_promotion.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}

resource "aws_lb_target_group" "staging_service_promotion" {
  name        = "${local.environment}-service-promotion"
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

resource "aws_lb_listener_rule" "staging_service_promotion" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 2031

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_promotion.arn
  }

  condition {
    host_header {
      values = ["promotion.sandbox.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "service-promotion"
    Environment = "${local.environment}"
  }
}
resource "cloudflare_record" "service_promotion" {
  zone_id = data.cloudflare_zone.root.id
  name    = "promotion.sandbox"
  value   = aws_lb.staging.dns_name
  type    = "CNAME"
  proxied = true
}


######
# service-kinesis-consumer-report
module "staging_service_kinesis_consumer_report" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-kinesis-consumer-report"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/service-kinesis-consumer-report:v1.0.8.1"


  env = {

    "CLICKHOUSE_ENDPOINT" : "http://10.10.61.189:8123",
    "CLICKHOUSE_USERNAME" : "default",
    "CLICKHOUSE_PASSWORD" : "cerwg3e62fhu0ajvijtan03l",
    "PROCESSOR_STREAM" : "staging_bet_result_stream",
    "PROCESSOR_REGION" : "ap-northeast-1",
    "PROCESSOR_NAME" : "staging-ReportConsumerApplication",
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
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}