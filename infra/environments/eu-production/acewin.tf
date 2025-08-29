
##############
### service-acewin-adaptor
#############
module "prd_eu_service_acewin_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-acewin-adaptor"

  app_name = "srv-acewin-adaptor"

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-acewin-adaptor:v1.0.28.1"


  env = {
    LOG_LEVEL                      = "error"
    NODE_ENV                       = "development"
    SGC_HOST                       = "http://srv-game-client"
    GAME_CODE_PREFIX               = "acewin-"
    API_HOST                       = "https://api.${local.aw_domain}"
    STATIC_HOST                    = "https://static.${local.aw_domain}"
    PORT                           = "8080"
    SERVICE_CLIENT_REQUEST_TIMEOUT = "10000"
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
      arn  = aws_lb_target_group.prd_eu_service_acewin_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.prd_eu_service,
    aws_iam_role_policy.prd_eu_service_policy,
  ]
}

resource "aws_lb_target_group" "prd_eu_service_acewin_adaptor" {
  name        = "${local.environment}-srv-acewin-adaptor"
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

resource "aws_lb_listener_rule" "prd_eu_service_acewin_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 2220

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prd_eu_service_acewin_adaptor.arn
  }

  condition {
    host_header {
      values = ["api.${local.aw_domain}"]
    }
  }

  tags = {
    Name        = "api.${local.aw_domain}"
    Environment = "prd_eu"
  }
}
