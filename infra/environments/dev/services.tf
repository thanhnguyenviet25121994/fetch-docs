data "aws_secretsmanager_secret" "dev_service_game_client_db" {
  name = "${local.environment}/service-game-client/db"
}

data "aws_secretsmanager_secret" "dev_service_operator_db" {
  name = "${local.environment}/service-operator/db"
}

data "aws_ecr_image" "service_game_client" {
  repository_name = "revengegames/service-game-client"
  image_tag       = local.service_game_client_version

}

data "aws_secretsmanager_secret" "dev_service_marketing_2" {
  name = "${local.environment}/service-marketing-2/env"
}


data "aws_secretsmanager_secret" "dev_service_promotion" {
  name = "${local.environment}/service-promotion/env"
}

module "dev_service_game_client" {
  providers = {
    aws = aws.current
  }

  source        = "../../modules/service-game-client"
  desired_count = 1

  task_size_cpu    = 2048
  task_size_memory = 4096

  filter_pattern = "{ $.message = \"[ERROR]\" && $.message != \"*Error during WebSocket session*\" && $.message != \"*Handling error for session*\" }"
  app_env        = local.environment
  image          = "${aws_ecr_repository.service_game_client.repository_url}:${local.service_game_client_version}"
  db = {
    endpoint        = aws_rds_cluster.dev_main.endpoint
    reader_endpoint = aws_rds_cluster.dev_main.reader_endpoint
    credentials     = data.aws_secretsmanager_secret.dev_service_game_client_db
    name            = "service_game_client"
  }
  # opensearch = {
  #   endpoint    = module.dev_opensearch_2.endpoint
  #   credentials = data.aws_secretsmanager_secret.dev_service_game_client_db
  # }

  env = {
    "JAVA_OPTS" : "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    "SERVICE_GAMEREPLAY_ENDPOINT" : "https://replay.dev.revenge-games.com/replay/"
    "SERVICE_ENTITY_ADDRESS" : "http://service-entity"
    "SYSTEM_LOGIC_VALIDATE" : "true"
    "SERVICE_COMMON_ASSETS_URL" : "https://common-assets-v3.${local.environment}.${local.root_domain}"
    "SERVICE_SHARED_UI_URL" : "https://share-ui-game-client.${local.environment}.${local.root_domain}"
    "AWS_DYNAMODB_TABLE_PLAYERATTRIBUTES" : "dev_player_attributes"
    "AWS_DYNAMODB_TABLE_BETRESULTS" : "dev_bet_results"
    "SPRING_DATA_REDIS_URL" : "rediss://dev-cache-diqjla.serverless.apse1.cache.amazonaws.com:6379"
    "SERVICE_WEBSOCKET_ENVURL" : "https://api.dev.revenge-games.com"
    "SERVICE_WEBSOCKET_URL" : "wss://api.dev.revenge-games.com/ws"
    "SYSTEM_LOGIC_DEBUG" : "true"
    "FEATURES_HISTORY_IMPL" : "cassandra"
    "SPRING_CASSANDRA_KEYSPACE_NAME" : "dev_keyspace"
    "SPRING_CASSANDRA_CONTACT_POINTS" : "cassandra.ap-southeast-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY" : "local_quorum"
    "SPRING_CASSANDRA_LOCAL_DATACENTER" : "ap-southeast-1"
    "FEATURE_PLAY_OPERATOR_CLIENT_DEBUG" : "false"
    "FEATURE_PLAY_LOGIC_CLIENT_DEBUG" : "true"
    "FEATURES_PROMOTION_CLIENT_URL" : "https://promotion.dev.revenge-games.com",

  }

  role = aws_iam_role.dev_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.dev_service_game_client.arn,
      port = 9300
    }]
  }

  services = {
    # service-game-client-dashboard = {
    #   env = {
    #     "SERVICE_GAMEREPLAY_ENDPOINT" : "https://replay.dev.revenge-games.com/replay/"
    #     "GRPC_CLIENT_ENTITY_ADDRESS" : "static://service-entity-grpc:81"
    #     "SYSTEM_DEBUG_ENABLED" : "true"
    #     "ORG_JOBRUNR_DASHBOARD_ENABLED" : "true"
    #     "ORG_JOBRUNR_BACKGROUND_JOB_SERVER_ENABLED" : "false"
    #     "ORG_JOBRUNR_DASHBOARD_PORT" : 9301
    #   }
    #   lb = {
    #     arn  = aws_lb_target_group.dev_service_game_client_dashboard.arn,
    #     port = 9301
    #   }
    # },
    # service-game-client-worker = {
    #   env = {
    #     "SERVICE_GAMEREPLAY_ENDPOINT" : "https://replay.dev.revenge-games.com/replay/"
    #     "GRPC_CLIENT_ENTITY_ADDRESS" : "static://service-entity-grpc:81"
    #     "SYSTEM_DEBUG_ENABLED" : "true"
    #     "ORG_JOBRUNR_DASHBOARD_ENABLED" : "false"
    #     "ORG_JOBRUNR_BACKGROUND_JOB_SERVER_ENABLED" : "true"
    #   }
    #   lb = {
    #     arn  = aws_lb_target_group.dev_service_game_client_dashboard.arn,
    #     port = 9301
    #   }
    # },
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}

resource "aws_lb_target_group" "dev_service_game_client" {
  name        = "${local.environment}-service-game-client"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

resource "aws_lb_target_group" "dev_service_game_client_2" {
  name        = "${local.environment}-service-game-client-2"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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



resource "aws_lb_listener_rule" "dev_service_game_client" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_game_client.arn
  }

  condition {
    host_header {
      values = ["api.${local.environment}.${local.root_domain}"]
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
    Name        = "api.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}


# resource "cloudflare_record" "service_operator" {
#   zone_id = data.cloudflare_zone.root.id
#   name    = "apibo.${local.environment}.${local.root_domain}"
#   value   = aws_lb.dev.dns_name
#   type    = "CNAME"
#   proxied = true
# }

###############
# service game client dashboard
##################

resource "aws_lb_target_group" "dev_service_game_client_dashboard" {
  name        = "${local.environment}-service-game-client-dash"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

resource "aws_lb_listener_rule" "dev_service_game_client_dashboard" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 207

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_game_client_dashboard.arn
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


resource "cloudflare_record" "dev_retry_dashboard" {
  zone_id = data.cloudflare_zone.root.id
  name    = "retry.${local.environment}.${local.root_domain}"
  value   = aws_lb.dev.dns_name
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "api_dev" {
  zone_id = data.cloudflare_zone.root.id
  name    = "api.${local.environment}.${local.root_domain}"
  value   = aws_lb.dev.dns_name
  type    = "CNAME"
  proxied = true
}

resource "aws_service_discovery_http_namespace" "dev" {
  name = local.environment
}

# module "dev_opensearch_2" {
#   source = "../../modules/service-opensearch"
#   providers = {
#     aws = aws.current
#   }

#   app_name = "opensearch-2"

#   app_env       = local.environment
#   region        = local.region
#   instance_type = "m7g.medium.search"
#   network_configuration = {
#     vpc = module.dev_networking.vpc
#     subnet_ids = [
#       module.dev_networking.subnet_private_1.id
#     ]
#   }
# }

# service-entity
resource "aws_lb_target_group" "dev_service_entity_http" {
  name        = "${local.environment}-service-entity-http"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

resource "aws_lb_listener_rule" "dev_service_entity_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 600

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_entity_http.arn
  }

  condition {
    host_header {
      values = ["entity.${local.environment}.${local.root_domain}", "bo.dev.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "entity.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}



# service-entity internal
# resource "aws_lb_target_group" "dev_service_entity_internal" {
#   name        = "${local.environment}-service-entity-internal"
#   port        = 80
#   protocol    = "HTTP"
#   protocol_version = "HTTP2"
#   vpc_id      = module.dev_networking.vpc.id
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

# resource "aws_lb_listener_rule" "dev_service_entity_internal" {
#   listener_arn = aws_lb_listener.http_internal.arn
#   priority     = 601

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.dev_service_entity_internal.arn
#   }

#   condition {
#     host_header {
#       values = ["service-entity.revenge-games.dev"]
#     }
#   }

#   tags = {
#     Name        = "entity-internal"
#     Environment = "${local.environment}"
#   }
# }

data "aws_secretsmanager_secret" "dev_service_entity_db" {
  name = "${local.environment}/service-entity/db"
}

data "aws_ecr_image" "service_entity" {
  repository_name = "revengegames/service-entity"
  image_tag       = local.service_entity_version
}

module "dev_service_entity" {
  source = "../../modules/service-entity"
  providers = {
    aws = aws.current
  }
  desired_count = 1

  app_env = local.environment
  image   = "211125478834.dkr.ecr.ap-southeast-1.amazonaws.com/revengegames/service-entity:${local.service_entity_version}"
  db = {
    endpoint    = aws_rds_cluster.dev_main.endpoint
    credentials = data.aws_secretsmanager_secret.dev_service_entity_db
    name        = "service_entity"
  }

  role = aws_iam_role.dev_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.dev_service_entity_http.arn,
      port = 9500
    }]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}


##############
### entity grpc
# module "dev_service_entity_grpc" {
#   source = "../../modules/service-entity"
#   providers = {
#     aws = aws.current
#   }
#   app_name           = "service-entity-grpc"
#   instance_count_min = 1
#   app_env            = local.environment
#   image              = "211125478834.dkr.ecr.ap-southeast-1.amazonaws.com/revengegames/service-entity:v1.0.177.1"
#   db = {
#     endpoint    = aws_rds_cluster.dev_main.endpoint
#     credentials = data.aws_secretsmanager_secret.dev_service_entity_db
#     name        = "service_entity"
#   }

#   role = aws_iam_role.dev_service
#   network_configuration = {
#     region = "${local.region}"
#     vpc    = module.dev_networking.vpc
#     subnets = [
#       module.dev_networking.subnet_private_1.id,
#       module.dev_networking.subnet_private_2.id
#     ]
#     security_groups = [
#       module.dev_networking.vpc.default_security_group_id
#     ]
#     load_balancer_target_groups = [{
#       arn  = aws_lb_target_group.dev_service_entity_grpc.arn,
#       port = 9501
#     }]
#   }

#   depends_on = [
#     aws_iam_role.dev_service,
#     aws_iam_role_policy.dev_service_policy,
#   ]
# }

# resource "aws_lb_target_group" "dev_service_entity_grpc" {
#   name             = "${local.environment}-service-entity-grpc"
#   port             = 80
#   protocol         = "HTTP"
#   protocol_version = "GRPC"
#   vpc_id           = module.dev_networking.vpc.id
#   target_type      = "ip"

#   health_check {
#     path                = "/AWS.ALB/healthcheck"
#     healthy_threshold   = 5
#     unhealthy_threshold = 10
#     port                = 9500
#     matcher             = "0-99"
#   }

#   tags = {
#     Environment = local.environment
#   }
# }

# resource "aws_lb_listener_rule" "dev_service_entity_grpc" {
#   listener_arn = aws_lb_listener.https.arn
#   priority     = 10

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.dev_service_entity_grpc.arn
#   }

#   condition {
#     host_header {
#       values = ["entity-grpc.dev.${local.root_domain}"]
#     }
#   }

#   tags = {
#     Name        = "entity-grpc.${local.environment}.${local.root_domain}"
#     Environment = "${local.environment}"
#   }
# }

# resource "cloudflare_record" "dev_service_entity_grpc" {
#   zone_id = data.cloudflare_zone.root.id
#   name    = "entity-grpc.dev"
#   content = aws_lb.dev.dns_name
#   type    = "CNAME"
#   proxied = false
# }

################
### Metabase
################
data "aws_secretsmanager_secret" "dev_service_metabase_db" {
  name = "${local.environment}/service-metabase/mb"
}

module "dev_service_metabase" {
  source = "../../modules/service-metabase"
  providers = {
    aws = aws.current
  }

  cluster_arn = module.dev_service_game_client.get_aws_ecs_cluster.arn

  instance_count_min = 1

  app_env = local.environment
  image   = "211125478834.dkr.ecr.ap-southeast-1.amazonaws.com/revengegames/metabase-clickhouse:v0.50.17"
  db = {
    endpoint    = aws_rds_cluster.dev_main.endpoint
    credentials = data.aws_secretsmanager_secret.dev_service_metabase_db
    name        = "service_metabase"
  }

  env = {
  }

  role = aws_iam_role.dev_service
  network_configuration = {
    region = local.region
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.dev_service_metabase.arn,
      port = 3000
    }]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}
resource "aws_lb_target_group" "dev_service_metabase" {
  name        = "${local.environment}-service-metabase"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

resource "aws_lb_listener_rule" "dev_service_metabase" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 700

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_metabase.arn
  }

  condition {
    host_header {
      values = ["ds.dev.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "ds.dev.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "dev_metabase" {
  zone_id = data.cloudflare_zone.root.id
  name    = "ds.dev.${local.root_domain}"
  value   = aws_lb.dev.dns_name
  type    = "CNAME"
  proxied = true
}



##############
### service-pp-adaptor
#############
module "dev_service_pp_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-pp-adaptor"

  app_env = local.environment
  image   = "${module.ecrs.repository_url_map["revengegames/service-pp-adaptor"]}:v1.0.290.1"

  role = aws_iam_role.dev_service

  env = {
    LOBBY_URL = "https://lobby.pp.dev.revenge-games.com",
  }
  network_configuration = {
    region = "${local.region}"
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.dev_service_pp_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}

resource "aws_lb_target_group" "dev_service_pp_adaptor" {
  name        = "${local.environment}-service-pp-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

resource "aws_lb_listener_rule" "dev_service_pp_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 209

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_pp_adaptor.arn
  }

  condition {
    host_header {
      values = ["pp.${local.environment}.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "pp.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}


#####################
### service-marketing-2
#####################


module "dev_service_marketing_2" {
  providers = {
    aws = aws.current
  }
  instance_count_min = 1
  source             = "../../modules/service-marketing-2"

  task_size_cpu    = 2048
  task_size_memory = 4096

  app_env = local.environment

  env = {
    "SPRING_DATA_REDIS_URL" : "rediss://dev-cache-diqjla.serverless.apse1.cache.amazonaws.com:6379",
    "SERVICE_ENTITY_ADDRESS" : "http://service-entity",
    "JAVA_OPTS" : "-Dlogging.level.com.revenge.marketing.v2.api=INFO"
  }
  image = "${module.ecrs.repository_url_map["revengegames/service-marketing-2"]}:v1.0.132.1"

  secrets = {
    credentials = data.aws_secretsmanager_secret.dev_service_marketing_2
  }

  role = aws_iam_role.dev_service

  network_configuration = {
    region = "${local.region}"
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = module.alb.target_groups["service-marketing-2"].arn,
      port = 9600
    }]
  }

}




locals {
  game_domains = [
    "rc.${local.dev_root_domain}",
    "as.${local.dev_root_domain}",
    "rg.${local.dev_root_domain}",
  ]
}

resource "aws_lb_listener_rule" "dev_service_game_client_2" {
  for_each = toset(local.game_domains)

  listener_arn = aws_lb_listener.http.arn
  priority     = 201 + index(local.game_domains, each.value)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_game_client.arn
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

resource "aws_lb_listener_rule" "dev_service_game_client_3" {
  for_each = toset(local.game_domains)

  listener_arn = aws_lb_listener.http.arn
  priority     = 231 + index(local.game_domains, each.value)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_game_client.arn
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


##############
### service-pgs-adaptor
#############
module "dev_service_pgs_adptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-pgs-adaptor"

  app_env = local.environment
  image   = "${module.ecrs.repository_url_map["revengegames/service-pgs-adaptor"]}:v1.0.60.2"

  env = {
    SGC_HOST            = "https://api.dev.revenge-games.com",
    API_HOST            = "https://api.pgs.dev.revenge-games.com",
    DISABLE_CACHE       = "true"
    M_HOST              = "https://m.pgs.dev.revenge-games.com"
    STATIC_HOST         = "https://static.pgs.dev.revenge-games.com"
    SGC_REQUEST_TIMEOUT = 10000
    GAME_CODE_PREFIX    = "pgs-"
    ERROR_MESSAGE       = "true"
  }

  role = aws_iam_role.dev_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.dev_service_pgs_adptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}

resource "aws_lb_target_group" "dev_service_pgs_adptor" {
  name        = "${local.environment}-service-pgs-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

resource "aws_lb_listener_rule" "dev_service_pgs_adptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 219

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_pgs_adptor.arn
  }

  condition {
    host_header {
      values = ["api.pgs.${local.environment}.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "pgs.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}



##############
### service-hacksaw-adaptor
#############
module "dev_service_hacksaw_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-hacksaw-adaptor"

  app_env = local.environment
  image   = "${module.ecrs.repository_url_map["revengegames/service-hacksaw-adaptor"]}:v1.0.6.1"

  env = {
    LOG_LEVEL                      = "debug"
    NODE_ENV                       = "development"
    SGC_HOST                       = "http://service-game-client"
    SERVICE_CLIENT_REQUEST_TIMEOUT = "10000"
    GAME_CODE_PREFIX               = "hs-"
    API_HOST                       = "https://api.hacksaw.dev.revenge-games.com"
    STATIC_HOST                    = "https://static.hacksaw.dev.revenge-games.com"
    PORT                           = "8080"
  }

  role = aws_iam_role.dev_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.dev_service_hacksaw_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}

resource "aws_lb_target_group" "dev_service_hacksaw_adaptor" {
  name        = "${local.environment}-service-hacksaw-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

resource "aws_lb_listener_rule" "dev_service_hacksaw_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 220

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_hacksaw_adaptor.arn
  }

  condition {
    host_header {
      values = ["api.hacksaw.${local.environment}.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "hacksaw.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}


##############
### service-transfer-wallet
#############
module "dev_service_transfer_wallet" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-transfer-wallet"

  app_env = local.environment
  image   = "${module.ecrs.repository_url_map["revengegames/service-transfer-wallet"]}:v1.0.107.1"

  env = {
    "JAVA_OPTS" : "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true"
    "SPRING_CASSANDRA_KEYSPACE_NAME" : "dev_keyspace"
    "SPRING_CASSANDRA_CONTACT_POINTS" : "cassandra.ap-southeast-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY" : "local_quorum"
    "SPRING_CASSANDRA_LOCAL_DATACENTER" : "ap-southeast-1"
    "SYSTEM_LOGIC_VALIDATE" : "true"
    "SPRING_DATA_REDIS_URL" : "rediss://dev-cache-diqjla.serverless.apse1.cache.amazonaws.com:6379"
    "PORT" : "9300"
    "SERVER_PORT" : 9300
    "SERVICE_ENTITY_ADDRESS" : "http://service-entity"
    "SYSTEM_SIGNATURE_HOST" : "api.dev.revenge-games.com"
  }

  role = aws_iam_role.dev_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.dev_service_transfer_wallet.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}

resource "aws_lb_target_group" "dev_service_transfer_wallet" {
  name        = "${local.environment}-service-transfer-wallet"
  port        = 9300
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

resource "aws_lb_listener_rule" "dev_service_transfer_wallet" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 229

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_transfer_wallet.arn
  }

  condition {
    host_header {
      values = ["transfer-wallet.${local.environment}.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "transfer-wallet.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "dev_service_transfer_wallet" {
  zone_id = data.cloudflare_zone.root.id
  name    = "transfer-wallet.dev"
  content = aws_lb.dev.dns_name
  type    = "CNAME"
  proxied = true
}




##############
### service-wf-adapter
#############
module "dev_service_wf_adapter" {
  providers = {
    aws = aws.current
  }

  task_size_cpu    = "2048"
  task_size_memory = "4096"

  source = "../../modules/service-wf-adapter"

  app_env = local.environment
  image   = "${module.ecrs.repository_url_map["revengegames/service-wf-adapter"]}:v1.0.7.1"

  env = {
    JAVA_OPTS : "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    SERVICE_GAMECLIENT_ADDRESS   = "https://api.dev.revenge-games.com"
    WEB_CLIENT_HOST              = "https://callbacks.dev.revenge-games.com"
    SERVICE_ENTITY_ADDRESS       = "http://service-entity"
    SERVICE_WFGAMING_SECRET      = "ISLK5OV0V9H12W65"
    SERVICE_WFGAMING_OPERATOR_ID = "wfRGstgBRL"
    SERVICE_WFGAMING_ADDRESS     = "https://smakermicsvc.back138.com/api/opgateway/v1/op/"
    SERVICE_WFGAMING_DEBUG       = "true"
    SPRING_DATA_REDIS_URL        = "rediss://dev-cache-diqjla.serverless.apse1.cache.amazonaws.com:6379"

    # game.client config
    SERVICE_GAMECLIENT_DEBUG = "true"
  }

  role = aws_iam_role.dev_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.dev_service_wf_adapter.arn,
      port = 9900
    }]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}

resource "aws_lb_target_group" "dev_service_wf_adapter" {
  name        = "${local.environment}-service-wf-adapter"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

resource "aws_lb_listener_rule" "dev_service_wf_adapter" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 221

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_wf_adapter.arn
  }

  condition {
    host_header {
      values = ["callbacks.${local.environment}.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "callbacks.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "dev_service_wf_adapter" {
  zone_id = data.cloudflare_zone.root.id
  name    = "callbacks.dev"
  content = aws_lb.dev.dns_name
  type    = "CNAME"
  proxied = true
}



##############
### service-promotion
#############
module "dev_service_promotion" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-promotion"

  app_env = local.environment
  image   = "${module.ecrs.repository_url_map["revengegames/service-promotion"]}:v1.0.247.1"

  env = {
    "JAVA_OPTS" : "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    "FEATURES_PROMOTION_CLIENT_URL" : "https://promotion.dev.revenge-games.com",
    "SERVICE_ENTITY_ADDRESS" : "http://service-entity",
    "SPRING_DATA_REDIS_URL" : "rediss://dev-promotion-valkey-diqjla.serverless.apse1.cache.amazonaws.com:6379"

  }

  secrets = {
    credentials = data.aws_secretsmanager_secret.dev_service_promotion
  }

  role = aws_iam_role.dev_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.dev_service_promotion.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}

resource "aws_lb_target_group" "dev_service_promotion" {
  name        = "${local.environment}-service-promotion"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

resource "aws_lb_listener_rule" "dev_service_promotion" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 2031

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_promotion.arn
  }

  condition {
    host_header {
      values = ["promotion.${local.environment}.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "service-promotion"
    Environment = "${local.environment}"
  }
}
resource "cloudflare_record" "service_promotion" {
  zone_id = data.cloudflare_zone.root.id
  name    = "promotion.dev"
  value   = aws_lb.dev.dns_name
  type    = "CNAME"
  proxied = true
}




##############
### service-leaderboard
#############
module "dev_service_leaderboard" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-leaderboard"

  app_env = local.environment
  image   = "${module.ecrs.repository_url_map["revengegames/service-leaderboard"]}:v1.0.3.1"

  env = {
    "JAVA_OPTS" : "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    "GRPC_CLIENT_ENTITY_ADDRESS" : "http://service-entity",
    "SPRING_CASSANDRA_KEYSPACE_NAME" : "dev_keyspace"
    "SPRING_CASSANDRA_CONTACT_POINTS" : "cassandra.ap-southeast-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY" : "local_quorum"
    "SPRING_CASSANDRA_LOCAL_DATACENTER" : "ap-southeast-1"
    "SPRING_CASSANDRA_SCHEMA_ACTION" : "CREATE_IF_NOT_EXISTS"
    "SPRING_DATA_REDIS_URL" : "rediss://dev-cache-diqjla.serverless.apse1.cache.amazonaws.com:6379"
  }


  role = aws_iam_role.dev_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.dev_service_leaderboard.arn,
      port = 9760
    }]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}

resource "aws_lb_target_group" "dev_service_leaderboard" {
  name        = "${local.environment}-service-leaderboard"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

resource "aws_lb_listener_rule" "dev_service_leaderboard" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 2030

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_leaderboard.arn
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
  name    = "leaderboard.dev"
  value   = aws_lb.dev.dns_name
  type    = "CNAME"
  proxied = true
}




##############
### service-jili-adapter
#############
module "dev_service_jili_adapter" {
  providers = {
    aws = aws.current
  }

  task_size_cpu    = "2048"
  task_size_memory = "4096"

  source = "../../modules/service-jili-adapter"

  app_env = local.environment
  image   = "${module.ecrs.repository_url_map["revengegames/service-jili-adapter"]}:v1.0.17.1"

  env = {
    JAVA_OPTS : "-XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dcom.linecorp.armeria.verboseResponses=true",
    SERVICE_GAMECLIENT_ADDRESS   = "https://api.dev.revenge-games.com"
    WEB_CLIENT_HOST              = "https://jili.dev.revenge-games.com"
    SERVICE_ENTITY_ADDRESS       = "http://service-entity"
    SERVICE_WFGAMING_SECRET      = "ISLK5OV0V9H12W65"
    SERVICE_WFGAMING_OPERATOR_ID = "wfRGstgBRL"
    SERVICE_WFGAMING_ADDRESS     = "https://smakermicsvc.back138.com/api/opgateway/v1/op/"
    SERVICE_WFGAMING_DEBUG       = "true"
    SPRING_DATA_REDIS_URL        = "rediss://dev-cache-diqjla.serverless.apse1.cache.amazonaws.com:6379"

    # game.client config
    SERVICE_GAMECLIENT_DEBUG = "true"
  }

  role = aws_iam_role.dev_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.dev_service_jili_adapter.arn,
      port = 9945
    }]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}

resource "aws_lb_target_group" "dev_service_jili_adapter" {
  name        = "${local.environment}-service-jili-adapter"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

resource "aws_lb_listener_rule" "dev_service_jili_adapter" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_jili_adapter.arn
  }

  condition {
    host_header {
      values = ["jili.${local.environment}.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "jili.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

# resource "cloudflare_record" "service_leaderboard" {
#   zone_id = data.cloudflare_zone.root.id
#   name    = "jilicallback.dev"
#   value   = aws_lb.dev.dns_name
#   type    = "CNAME"
#   proxied = true
# }




######
# service-player-retention
module "dev_service_player_retention" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-player-retention"

  app_env = local.environment
  image   = "${module.ecrs.repository_url_map["revengegames/service-player-retention"]}:v1.0.13.1"

  env = {

    "REGION" : "ap-southeast-1",
    "STREAM_NAME" : "dev_bet_result_2__kinesis",
    "GPT_MODEL" : "gpt-4.1",
    "OPENAI_API_KEY" : "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",
    "DYNAMO_ENDPOINT" : "https://dynamodb.ap-southeast-1.amazonaws.com",
    "MAX_RETRIES" : "5",
    "RETRY_BACKOFF_BASE" : "2",

    "ANALYSIS_TABLE" : "dev-GptAnalysisResults",
    "SHARD_STATE_TABLE" : "dev-KinesisShardState"
    "PG_HOST" : "dev-20240325154059614700000001.cluster-criumeeyoizm.ap-southeast-1.rds.amazonaws.com",
    "PG_PORT" : "5432",
    "PG_USER" : "service_entity",
    "PG_PASSWORD" : "dev/operator_demo/20240325154059614700000001",
    "PG_DATABASE" : "service_entity",
  }


  role = aws_iam_role.dev_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}

######
# service-killer-game-server
######

module "dev_service_killer_game_server" {
  providers = {
    aws = aws.current
  }
  app_name = "service-killer-game-server"
  source   = "../../modules/service-killer-game-server"

  app_env = local.environment
  image   = "${module.ecrs.repository_url_map["revengegames/service-killer-game-server"]}:v1.0.2.1"

  env = {
    "SERVER_PORT" : 9400,
    "SGC_HOST" : "http://service-game-client"
    "SPRING_DATA_REDIS_URL" : "rediss://dev-cache-diqjla.serverless.apse1.cache.amazonaws.com:6379"
    "SPRING_DATA_REDIS_TIMEOUT" : 5000
  }

  role = aws_iam_role.dev_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.dev_service_killer_game_server.arn,
      port = 9400
    }]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}

resource "aws_lb_target_group" "dev_service_killer_game_server" {
  name        = "${local.environment}-service-killer-game-server"
  port        = 9400
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

resource "aws_lb_listener_rule" "service_killer_game_server" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 239

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_killer_game_server.arn
  }

  condition {
    host_header {
      values = ["kgs.${local.environment}.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "kgs.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "service_killer_game_server" {
  zone_id = data.cloudflare_zone.root.id
  name    = "kgs.dev"
  content = aws_lb.dev.dns_name
  type    = "CNAME"
  proxied = true
}



######
# service-kinesis-consumer-report
module "dev_service_kinesis_consumer_reportnal" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-kinesis-consumer-report"

  app_env = local.environment
  image   = "${module.ecrs.repository_url_map["revengegames/service-kinesis-consumer-report"]}:v1.0.2.1"

  env = {

    "CLICKHOUSE_ENDPOINT" : "http://54.178.243.185:8123",
    "CLICKHOUSE_USERNAME" : "default",
    "CLICKHOUSE_PASSWORD" : "cerwg3e62fhu0ajvijtan03l",
    "PROCESSOR_STREAM" : "dev_bet_result_2__kinesis",
    "PROCESSOR_REGION" : "ap-southeast-1",
    "PROCESSOR_NAME" : "dev-ReportConsumerApplication",
  }


  role = aws_iam_role.dev_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.dev_networking.vpc
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}