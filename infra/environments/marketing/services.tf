data "aws_secretsmanager_secret" "mkt_service_game_client_db" {
  name = "${local.environment}/service-game-client/db"
}

module "mkt_service_game_client" {
  source = "../../modules/service-game-client-2"
  providers = {
    aws = aws.current
  }
  task_size_memory = 4096
  task_size_cpu    = 2048

  desired_count = 1

  app_env        = local.environment
  filter_pattern = "[ERROR]"

  image = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-client:${local.service_game_client_version}"
  # db = {
  #   endpoint        = aws_rds_cluster.mkt_main.endpoint
  #   reader_endpoint = aws_rds_cluster.mkt_main.reader_endpoint
  #   credentials     = data.aws_secretsmanager_secret.mkt_service_game_client_db
  #   name            = "service_game_client"
  # }

  env = {
    "MANAGEMENT_TRACING_ENABLED" : false
    "MANAGEMENT_TRACING_SAMPLING_PROBABILITY" : 0.1
    "PLAYER_ONLINE_EXPIRY" : "PT2H"
    "SERVER_PORT" : 9300
    "JAVA_OPTS" : "-Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dlogging.level.com.revenge.game.features.play=OFF"
    "SERVICE_GAMEREPLAY_ENDPOINT" : "https://replay.${local.root_domain}/replay/"
    "SERVICE_ENTITY_ADDRESS" : "https://entity.revenge-games.gmkt"
    "SYSTEM_DEBUG_ENABLED" : "true"
    "SERVICE_COMMON_ASSETS_URL" : "https://rgg.rg-lgna.com/common-assets"
    "SERVICE_SHARED_UI_URL" : "https://uig.mkt.rg-lgna.com"
    "SERVICE_WEBSOCKET_URL" : "wss://mkt.${local.root_domain}/ws"
    "SERVICE_WEBSOCKET_ENVURL" : "https://mkt.${local.root_domain}"
    "SPRING_DATA_REDIS_URL" : "rediss://mkt-valkey-a5rxt5.serverless.sae1.cache.amazonaws.com:6379"
    "FEATURES_HISTORY_IMPL" : "cassandra"
    "FEATURES_PLAY_LOGIC_CLIENT_DEBUG" : false
    "FEATURES_PLAY_OPERATOR_CLIENT_DEBUG" : false
    "SPRING_CASSANDRA_KEYSPACE_NAME" : "mkt_keyspace"
    "SPRING_CASSANDRA_CONTACT_POINTS" : "cassandra.sa-east-1.amazonaws.com:9142"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY" : "local_quorum"
    "SPRING_CASSANDRA_LOCAL_DATACENTER" : "sa-east-1"
  }

  services = {
    # service-game-client-dashboard = {

  }

  role = aws_iam_role.mkt_service
  network_configuration = {
    region = local.region
    vpc    = module.mkt_networking.vpc
    subnets = [
      module.mkt_networking.subnet_private_1.id,
      module.mkt_networking.subnet_private_2.id
    ]
    security_groups = [
      module.mkt_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.mkt_service_game_client.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.mkt_service,
    aws_iam_role_policy.mkt_service_policy,
  ]
}

resource "aws_lb_target_group" "mkt_service_game_client" {
  name        = "${local.environment}-service-game-client"
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

resource "aws_lb_listener_rule" "mkt_service_game_client" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mkt_service_game_client.arn
  }

  condition {
    host_header {
      values = ["mkt.rg-lgna.com", "apig.mkt.rg-lgna.com"]
    }
  }

  tags = {
    Name        = "api.rg-lgna.com"
    Environment = "${local.environment}"
  }
}


data "aws_secretsmanager_secret" "mkt_dms_rds" {
  name = "${local.environment}/dms/rds"
}

data "aws_secretsmanager_secret" "mkt_service_entity_db" {
  name = "${local.environment}/service-entity/db"
}

module "mkt_service_entity" {
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
    endpoint    = aws_rds_cluster.mkt_main.endpoint
    credentials = data.aws_secretsmanager_secret.mkt_service_entity_db
    name        = "service_entity"
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
      arn  = aws_lb_target_group.mkt_service_entity_http.arn,
      port = 9500
    }]
  }

  depends_on = [
    aws_iam_role.mkt_service,
    aws_iam_role_policy.mkt_service_policy,
  ]
}

resource "aws_lb_target_group" "mkt_service_entity_http" {
  name        = "${local.environment}-service-entity-http"
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

resource "aws_lb_listener_rule" "mkt_service_entity_http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 600

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mkt_service_entity_http.arn
  }

  condition {
    host_header {
      values = ["mkt-bo.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "mkt-bo.${local.root_domain}"
    Environment = "${local.environment}"
  }
}





#########################
#### service marketing 2
#########################
data "aws_secretsmanager_secret" "mkt_service_marketing_2" {
  name = "${local.environment}/service-marketing-2/env"
}
module "mkt_service_marketing_2" {
  providers = {
    aws = aws.current
  }
  instance_count_min = 1
  source             = "../../modules/service-marketing-2"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-marketing-2:v1.0.123.1"


  env = {
    SPRING_DATA_REDIS_URL  = "rediss://mkt-valkey-a5rxt5.serverless.sae1.cache.amazonaws.com:6379",
    SERVICE_ENTITY_ADDRESS = "http://service-entity-grpc:81",
    JAVA_OPTS              = "-Dlogging.level.org.slf4j=DEBUG"

  }

  secrets = {
    credentials = data.aws_secretsmanager_secret.mkt_service_marketing_2
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
      arn  = aws_lb_target_group.mkt_service_marketing_2.arn,
      port = 9600
    }]
  }

}

resource "aws_lb_target_group" "mkt_service_marketing_2" {
  name        = "${local.environment}-service-marketing-2"
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

resource "aws_lb_listener_rule" "mkt_service_marketing_2" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 210

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mkt_service_marketing_2.arn
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
