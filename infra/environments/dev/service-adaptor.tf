##############
### service-game-crash
#############
module "dev_service_game_crash" {
  source = "../../modules/service-adaptor"

  # task_size_cpu    = "512"
  # task_size_memory = "1024"

  app_name = "service-game-crash"

  app_env = local.environment
  image   = "${module.ecrs.repository_url_map["revengegames/service-game-crash"]}:v1.0.23.1"

  env = {
    PLAYER_ONLINE_EXPIRY   = "PT2H"
    SERVER_PORT            = 9300
    SERVICE_ENTITY_ADDRESS = "http://service-entity"
    SERVICE_GAME_URL       = "http://service-game-client"
    SPRING_DATA_REDIS_URL  = "rediss://dev-cache-diqjla.serverless.apse1.cache.amazonaws.com:6379"
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
      arn  = aws_lb_target_group.dev_service_game_crash.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}

resource "aws_lb_target_group" "dev_service_game_crash" {
  name        = "${local.environment}-service-game-crash"
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

resource "aws_lb_listener_rule" "dev_service_game_crash" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 51

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_game_crash.arn
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
resource "cloudflare_record" "dev_service_game_crash" {
  zone_id = data.cloudflare_zone.root.id
  name    = "apicrash.dev"
  value   = aws_lb.dev.dns_name
  type    = "CNAME"
  proxied = true
}


######
# service-config-server
module "dev_service_config_server" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-config-server"

  app_env = local.environment
  image   = "${module.ecrs.repository_url_map["revengegames/service-config-server"]}:v1.0.2.1"

  env = {

    "server.port" : "8888",
    "spring.profiles.active" : "awss3",
    "spring.cloud.config.server.awss3.region" : "ap-southeast-1",
    "spring.cloud.config.server.awss3.bucket" : "revengegames-dev-config",
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




module "dev_service_gma_adaptor" {
  source = "../../modules/service-adaptor"

  task_size_cpu    = "512"
  task_size_memory = "1024"

  app_name = "service-gma-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-gma-adaptor:v1.0.5.1"

  env = {
    SERVER_PORT           = 9300
    SPRING_DATA_REDIS_URL = "rediss://dev-cache-diqjla.serverless.apse1.cache.amazonaws.com:6379"

  }

  public_route = true
  role         = aws_iam_role.dev_service
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

    # load_balancer_target_groups = [{
    #   arn  = aws_lb_target_group.dev_service_gma_adaptor.arn,
    #   port = 9300
    # }]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}