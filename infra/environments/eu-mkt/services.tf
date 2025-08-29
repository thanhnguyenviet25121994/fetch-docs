resource "aws_service_discovery_http_namespace" "mkt_eu" {
  name = local.environment
}

data "aws_secretsmanager_secret" "mkt_eu_service_entity_db" {
  name = "${local.environment}/service-entity/db"
}

module "mkt_eu_service_entity" {
  source = "../../modules/service-entity"
  providers = {
    aws = aws.current
  }
  task_size_cpu      = 2048
  task_size_memory   = 4096
  desired_count      = 1
  instance_count_min = 1

  app_name = "srv-entity"
  app_env  = local.environment
  image    = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-entity:${local.service_entity_version}"
  db = {
    endpoint    = aws_rds_cluster.mkt_eu_main.endpoint
    credentials = data.aws_secretsmanager_secret.mkt_eu_service_entity_db
    name        = "service_entity"
  }

  role = aws_iam_role.mkt_eu_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.mkt_eu_networking.vpc
    subnets = [
      module.mkt_eu_networking.subnet_private_1.id,
      module.mkt_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.mkt_eu_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.mkt_eu_service_entity_http.arn,
      port = 9500
    }]
  }

  depends_on = [
    aws_iam_role.mkt_eu_service,
    aws_iam_role_policy.mkt_eu_service_policy,
    aws_service_discovery_http_namespace.mkt_eu,
  ]
}

resource "aws_lb_target_group" "mkt_eu_service_entity_http" {
  name        = "${local.environment}-srv-entity-http"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.mkt_eu_networking.vpc.id
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

resource "aws_lb_listener_rule" "mkt_eu_service_entity_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 600

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mkt_eu_service_entity_http.arn
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

data "aws_secretsmanager_secret" "mkt_eu_service_game_client_db" {
  name = "${local.environment}/service-game-client/db"
}

module "mkt_eu_service_game_client" {
  providers = {
    aws = aws.current
  }

  source           = "../../modules/service-game-client-2"
  task_size_cpu    = 2048
  task_size_memory = 4096
  desired_count    = 1

  filter_pattern = "[ERROR]"
  app_name       = "srv-game-client"
  app_env        = local.environment
  image          = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-client:v1.0.1556.1"
  # db = {
  #   endpoint        = aws_rds_cluster.mkt_eu_main.endpoint
  #   reader_endpoint = aws_rds_cluster.mkt_eu_main.reader_endpoint
  #   credentials     = data.aws_secretsmanager_secret.mkt_eu_service_game_client_db
  #   name            = "service_game_client"
  # }

  env = {
    "MANAGEMENT_TRACING_ENABLED" : "false"
    "MANAGEMENT_TRACING_SAMPLING_PROBABILITY" : "0.1"
    "JAVA_OPTS" : "-Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dlogging.level.com.revenge.game.features.play=OFF"
    "SERVICE_GAMEREPLAY_ENDPOINT" : "https://replay.mkt.${local.root_domain}/replay/"
    # "SERVICE_ENTITY_ADDRESS" : "http://srv-entity-grpc:81"
    "SERVICE_ENTITY_ADDRESS" : "https://entity.revenge-games.gmkt"
    "AWS_DYNAMODB_TABLE_BETRESULTS" : "${local.environment}_bet_results"
    "ATTRIBUTE_DYNAMODBATTRIBUTESTABLE" : "${local.environment}_player_attributes"
    "AWS_DYNAMODB_TABLE_PLAYERATTRIBUTES" : "${local.environment}_player_attributes"
    "SYSTEM_DEBUG_ENABLED" : "true"
    "SERVICE_COMMON_ASSETS_URL" : "https://rgg.${local.rg_domain}/common-assets"
    "SERVICE_SHARED_UI_URL" : "https://uig.mkt.${local.rg_domain}"
    "SERVICE_WEBSOCKET_URL" : "wss://apig.mkt.${local.rg_domain}/ws"
    "SERVICE_WEBSOCKET_ENVURL" : "https://apig.mkt.${local.rg_domain}"
    "SPRING_DATA_REDIS_URL" : "rediss://mkt-eu-valkey-fe3a5n.serverless.euw1.cache.amazonaws.com:6379"
    "SYSTEM_LOGIC_VALIDATE" : "true"
    "SYSTEM_LOGIC_DEBUG" : "true"
    "FEATURES_HISTORY_IMPL" : "cassandra"
    "SPRING_CASSANDRA_KEYSPACE_NAME" : "mkt_keyspace"
    "SPRING_CASSANDRA_CONTACT_POINTS" : "cassandra.eu-west-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY" : "local_quorum"
    "SPRING_CASSANDRA_LOCAL_DATACENTER" : "eu-west-1"
    "FEATURE_PLAY_OPERATOR_CLIENT_DEBUG" : "true"
    "FEATURE_PLAY_LOGIC_CLIENT_DEBUG" : "false"
    "LOGGING_LEVEL_COM_REVENGE_GAME_API" : "INFO"
    "SYSTEM_ERROR_DEBUG" : "false"
  }



  role = aws_iam_role.mkt_eu_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.mkt_eu_networking.vpc
    subnets = [
      module.mkt_eu_networking.subnet_private_1.id,
      module.mkt_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.mkt_eu_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.mkt_eu_service_game_client.arn,
      port = 9300
    }]
  }
  services = {
  }

  depends_on = [
    aws_iam_role.mkt_eu_service,
    aws_iam_role_policy.mkt_eu_service_policy,
  ]
}

##########
resource "aws_lb_target_group" "mkt_eu_service_game_client" {
  name        = "${local.environment}-srv-game-client"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.mkt_eu_networking.vpc.id
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


resource "aws_lb_listener_rule" "mkt_eu_service_game_client" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mkt_eu_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        "api.mkt.${local.root_domain}",
        "apig.mkt.rg-lgna.com"
      ]
    }
  }

  condition {
    path_pattern {
      values = [
        "*",
      ]
    }
  }

  tags = {
    Name        = "srv-game-client"
    Environment = "${local.environment}"
  }
}


# module "mkt_eu_opensearch" {
#   source = "../../modules/service-opensearch"
#   providers = {
#     aws = aws.current
#   }

#   app_env       = local.environment
#   region        = local.region
#   volume_size   = 100
#   instance_type = "or1.medium.search"
#   network_configuration = {
#     vpc = module.mkt_eu_networking.vpc
#     subnet_ids = [
#       module.mkt_eu_networking.subnet_private_1.id
#     ]
#   }
# }

resource "cloudflare_record" "mkt_eu_api" {
  zone_id = data.cloudflare_zone.root.id
  name    = "api.mkt.${local.root_domain}"
  content = aws_lb.mkt_eu.dns_name
  type    = "CNAME"
  proxied = true
}

# #########################
# #### service marketing 2
# #########################
data "aws_secretsmanager_secret" "mkt_eu_service_marketing_2" {
  name = "${local.environment}/service-marketing-2/db"
}
module "mkt_eu_service_marketing_2" {
  providers = {
    aws = aws.current
  }
  instance_count_min = 1
  source             = "../../modules/service-marketing-2"

  task_size_cpu    = 2048
  task_size_memory = 4096

  app_name = "srv-marketing-2"
  app_env  = local.environment
  image    = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-marketing-2:v1.0.123.1"


  secrets = {
    credentials = data.aws_secretsmanager_secret.mkt_eu_service_marketing_2
  }

  env = {
    SPRING_DATA_REDIS_URL  = "rediss://mkt-eu-valkey-fe3a5n.serverless.euw1.cache.amazonaws.com:6379",
    SERVICE_ENTITY_ADDRESS = "http://service-entity-grpc:81",
    JAVA_OPTS              = "-Dlogging.level.org.slf4j=DEBUG"

  }

  role = aws_iam_role.mkt_eu_service

  network_configuration = {
    region = "${local.region}"
    vpc    = module.mkt_eu_networking.vpc
    subnets = [
      module.mkt_eu_networking.subnet_private_1.id,
      module.mkt_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.mkt_eu_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.mkt_eu_service_marketing_2.arn,
      port = 9600
    }]
  }

}

resource "aws_lb_target_group" "mkt_eu_service_marketing_2" {
  name        = "${local.environment}-srv-marketing-2"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.mkt_eu_networking.vpc.id
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

resource "aws_lb_listener_rule" "mkt_eu_service_marketing_2" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 210

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mkt_eu_service_marketing_2.arn
  }

  condition {
    host_header {
      values = ["studio.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "studio.${local.root_domain}"
    Environment = "${local.environment}"
  }
}