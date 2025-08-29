resource "aws_service_discovery_http_namespace" "mkt_asia" {
  name = local.environment
}

data "aws_secretsmanager_secret" "mkt_asia_service_entity_db" {
  name = "${local.environment}/service-entity/db"
}

module "mkt_asia_service_entity" {
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
    endpoint    = aws_rds_cluster.mkt_asia_main.endpoint
    credentials = data.aws_secretsmanager_secret.mkt_asia_service_entity_db
    name        = "service_entity"
  }

  role = aws_iam_role.mkt_asia_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.mkt_asia_networking.vpc
    subnets = [
      module.mkt_asia_networking.subnet_private_1.id,
      module.mkt_asia_networking.subnet_private_2.id
    ]
    security_groups = [
      module.mkt_asia_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.mkt_asia_service_entity_http.arn,
      port = 9500
      },
      {
        arn  = aws_lb_target_group.mkt_asia_service_entity_grpc.arn,
        port = 9501
    }]
  }

  depends_on = [
    aws_iam_role.mkt_asia_service,
    aws_iam_role_policy.mkt_asia_service_policy,
    aws_service_discovery_http_namespace.mkt_asia,
  ]
}

resource "aws_lb_target_group" "mkt_asia_service_entity_http" {
  name        = "${local.environment}-service-entity-http"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.mkt_asia_networking.vpc.id
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

resource "aws_lb_listener_rule" "mkt_asia_service_entity_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 600

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mkt_asia_service_entity_http.arn
  }

  condition {
    host_header {
      values = ["entity.mkt.${local.root_domain}", "bo.mkt.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "entity.mkt.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_target_group" "mkt_asia_service_entity_grpc" {
  name             = "${local.environment}-service-entity-grpc"
  port             = 80
  protocol         = "HTTP"
  protocol_version = "GRPC"
  vpc_id           = module.mkt_asia_networking.vpc.id
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


resource "aws_lb_listener_rule" "mkt_asia_service_entity_grpc" {
  listener_arn = aws_lb_listener.https_private.arn
  priority     = 600

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mkt_asia_service_entity_grpc.arn
  }

  condition {
    host_header {
      values = ["entity.revenge-games.gmkt"]
    }
  }

  tags = {
    Name        = "entity.revenge-games.gmke"
    Environment = "${local.environment}"
  }
}




data "aws_secretsmanager_secret" "mkt_asia_service_game_client_db" {
  name = "${local.environment}/service-game-client/db"
}

module "mkt_asia_service_game_client" {
  providers = {
    aws = aws.current
  }

  source           = "../../modules/service-game-client-2"
  task_size_cpu    = 2048
  task_size_memory = 4096
  desired_count    = 1

  filter_pattern = "[ERROR]"
  app_name       = "service-game-client"
  app_env        = local.environment
  image          = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-client:${local.service_game_client_version}"
  # db = {
  #   endpoint        = aws_rds_cluster.mkt_asia_main.endpoint
  #   reader_endpoint = aws_rds_cluster.mkt_asia_main.reader_endpoint
  #   credentials     = data.aws_secretsmanager_secret.mkt_asia_service_game_client_db
  #   name            = "service_game_client"
  # }

  # opensearch = {
  #   endpoint    = module.mkt_asia_opensearch.endpoint
  #   credentials = data.aws_secretsmanager_secret.mkt_asia_service_game_client_db
  # }
  # env = {
  #   "SERVICE_GAMEREPLAY_ENDPOINT" : "https://replay.${local.root_domain}/replay/"
  #   "GRPC_CLIENT_ENTITY_ADDRESS" : "http://service-entity-grpc:81"
  #   "AWS_DYNAMODB_TABLE_BETRESULTS" : "${local.environment}_bet_results"
  #   "ATTRIBUTE_DYNAMODBATTRIBUTESTABLE" : "${local.environment}_player_attributes"
  #   "AWS_DYNAMODB_TABLE_PLAYERATTRIBUTES" : "${local.environment}_player_attributes"
  #   "SYSTEM_DEBUG_ENABLED" : "true"
  # }

  env = {
    "FEATURES_PLAY_LOGIC_CLIENT_DEBUG"        = "false"
    "FEATURES_PLAY_OPERATOR_CLIENT_DEBUG"     = "false"
    "JAVA_OPTS"                               = "-Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dlogging.level.com.revenge.game.features.play=OFF"
    "LOGGING_LEVEL_COM_REVENGE_GAME_API"      = "INFO"
    "MANAGEMENT_TRACING_ENABLED"              = "false"
    "MANAGEMENT_TRACING_SAMPLING_PROBABILITY" = "0.1"
    "PLAYER_ONLINE_EXPIRY"                    = "PT2H"
    "SERVER_PORT"                             = "9300"
    "SERVICE_COMMON_ASSETS_URL"               = "https://rgg.${local.rg_domain}/common-assets"
    "SERVICE_ENTITY_ADDRESS"                  = "https://entity.revenge-games.gmkt"
    "SERVICE_GAMEREPLAY_ENDPOINT"             = "https://replay.rg-aslgna.com/replay/"
    "SERVICE_SHARED_UI_URL"                   = "https://uig.mkt.${local.rg_domain}"
    "SERVICE_WEBSOCKET_ENVURL"                = "https://apig.mkt.${local.rg_domain}"
    "SERVICE_WEBSOCKET_URL"                   = "wss://apig.mkt.${local.rg_domain}/ws"
    "SPRING_CASSANDRA_CONTACT_POINTS"         = "cassandra.ap-southeast-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_KEYSPACE_NAME"          = "mkt_keyspace"
    "SPRING_CASSANDRA_LOCAL_DATACENTER"       = "ap-southeast-1"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY"    = "local_quorum"
    "SPRING_DATA_REDIS_URL"                   = "rediss://mkt-asia-valkey-diqjla.serverless.apse1.cache.amazonaws.com:6379"
    "SYSTEM_DEBUG_ENABLED"                    = "false"
    "SYSTEM_ERROR_DEBUG"                      = "false"
    "SYSTEM_LOGIC_DEBUG"                      = "false"
    "SYSTEM_LOGIC_VALIDATE"                   = "false"
  }
  role = aws_iam_role.mkt_asia_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.mkt_asia_networking.vpc
    subnets = [
      module.mkt_asia_networking.subnet_private_1.id,
      module.mkt_asia_networking.subnet_private_2.id
    ]
    security_groups = [
      module.mkt_asia_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.mkt_asia_service_game_client.arn,
      port = 9300
    }]
  }
  services = {
  }

  depends_on = [
    aws_iam_role.mkt_asia_service,
    aws_iam_role_policy.mkt_asia_service_policy,
  ]
}

##########
resource "aws_lb_target_group" "mkt_asia_service_game_client" {
  name        = "${local.environment}-service-game-client"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.mkt_asia_networking.vpc.id
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


resource "aws_lb_listener_rule" "mkt_asia_service_game_client" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mkt_asia_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        "apig.mkt.${local.rg_domain}",
        "api.mkt.${local.root_domain}"
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
    Name        = "service-game-client"
    Environment = "${local.environment}"
  }
}


# module "mkt_asia_opensearch" {
#   source = "../../modules/service-opensearch"
#   providers = {
#     aws = aws.current
#   }

#   app_env       = local.environment
#   region        = local.region
#   volume_size   = 100
#   instance_type = "or1.medium.search"
#   network_configuration = {
#     vpc = module.mkt_asia_networking.vpc
#     subnet_ids = [
#       module.mkt_asia_networking.subnet_private_1.id
#     ]
#   }
# }

resource "cloudflare_record" "mkt_asia_api" {
  zone_id = data.cloudflare_zone.root.id
  name    = "api.mkt.${local.root_domain}"
  content = aws_lb.mkt_asia.dns_name
  type    = "CNAME"
  proxied = true
}

# #########################
# #### service marketing 2
# #########################
data "aws_secretsmanager_secret" "mkt_asia_service_marketing_2" {
  name = "${local.environment}/service-marketing-2/db"
}
module "mkt_asia_service_marketing_2" {
  providers = {
    aws = aws.current
  }
  instance_count_min = 1
  source             = "../../modules/service-marketing-2"

  task_size_cpu    = 2048
  task_size_memory = 4096

  app_name = "service-marketing-2"
  app_env  = local.environment
  image    = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-marketing-2:v1.0.127.1"

  env = {
    SPRING_DATA_REDIS_URL  = "rediss://mkt-asia-valkey-diqjla.serverless.apse1.cache.amazonaws.com:6379",
    SERVICE_ENTITY_ADDRESS = "http://service-entity",
    JAVA_OPTS              = "-Dlogging.level.org.slf4j=DEBUG"

  }
  secrets = {
    credentials = data.aws_secretsmanager_secret.mkt_asia_service_marketing_2
  }

  role = aws_iam_role.mkt_asia_service

  network_configuration = {
    region = "${local.region}"
    vpc    = module.mkt_asia_networking.vpc
    subnets = [
      module.mkt_asia_networking.subnet_private_1.id,
      module.mkt_asia_networking.subnet_private_2.id
    ]
    security_groups = [
      module.mkt_asia_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.mkt_asia_service_marketing_2.arn,
      port = 9600
    }]
  }

}

resource "aws_lb_target_group" "mkt_asia_service_marketing_2" {
  name        = "${local.environment}-service-marketing-2"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.mkt_asia_networking.vpc.id
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

resource "aws_lb_listener_rule" "mkt_asia_service_marketing_2" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 210

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mkt_asia_service_marketing_2.arn
  }

  condition {
    host_header {
      values = ["studio.mkt.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "studio.mkt.${local.root_domain}"
    Environment = "${local.environment}"
  }
}



resource "cloudflare_record" "mkt_api_global" {
  zone_id = data.cloudflare_zone.rg.id
  name    = "apig.mkt.${local.rg_domain}"
  content = module.global_accelerator.dns_name
  type    = "CNAME"
  proxied = true
}




##############
### service-promotion
#############

data "aws_secretsmanager_secret" "mkt_asia_service_promotion" {
  name = "${local.environment}/service-promotion/env"
}
module "mkt_asia_service_promotion" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-promotion"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-promotion:v1.0.263.1"


  env = {
    "JAVA_OPTS" : "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    "FEATURES_PROMOTION_CLIENT_URL" : "https://promo-api.mkt.rg-lgna.com",
    "SERVICE_ENTITY_ADDRESS" : "http://service-entity",
    "SPRING_DATA_REDIS_URL" : "rediss://mkt-asia-valkey-diqjla.serverless.apse1.cache.amazonaws.com:6379",
    "SYSTEM_SIGNATURE_HOST" : "promo-api.mkt.rg-lgna.com",
    "LOG_LEVEL" : "debug"
  }

  secrets = {
    credentials = data.aws_secretsmanager_secret.mkt_asia_service_promotion
  }

  role = aws_iam_role.mkt_asia_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.mkt_asia_networking.vpc
    subnets = [
      module.mkt_asia_networking.subnet_private_1.id,
      module.mkt_asia_networking.subnet_private_2.id
    ]
    security_groups = [
      module.mkt_asia_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.mkt_asia_service_promotion.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.mkt_asia_service,
    aws_iam_role_policy.mkt_asia_service_policy,
  ]
}

resource "aws_lb_target_group" "mkt_asia_service_promotion" {
  name        = "${local.environment}-service-promotion"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.mkt_asia_networking.vpc.id
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

resource "aws_lb_listener_rule" "mkt_asia_service_promotion" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 2031

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mkt_asia_service_promotion.arn
  }

  condition {
    host_header {
      values = ["promo-api.mkt.rg-lgna.com"]
    }
  }

  tags = {
    Name        = "service-promotion"
    Environment = "${local.environment}"
  }
}
resource "cloudflare_record" "service_promotion" {
  zone_id = data.cloudflare_zone.rg.id
  name    = "promo-api.mkt"
  value   = aws_lb.mkt_asia.dns_name
  type    = "CNAME"
  proxied = true
}