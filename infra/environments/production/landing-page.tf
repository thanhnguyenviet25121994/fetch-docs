module "prod_web_landing_page" {
  source = "../../modules/web-landing-page"
  providers = {
    aws = aws.current
  }

  app_env   = local.environment
  domain    = "rectangle-games.com"
  image     = "211125478834.dkr.ecr.ap-southeast-1.amazonaws.com/revengegames/web-landing-page:v1.0.38.1"
  value_dns = aws_lb.prod.dns_name
  app_dns   = "rectangle-games.com"
  role      = aws_iam_role.prod_service
  env = [{
    name  = "MAILER_SENDER_EMAIL",
    value = "do-not-reply@rectangle-games.com"
    },
    {
      name  = "MAILER_RECIPIENT_EMAILS",
      value = "contact@rectangle-games.com,paulo.wong@revenge.games"
    },
    { name  = "AWS_REGION",
      value = "ap-southeast-1"
    }
  ]

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
    load_balancer = aws_lb.prod
  }

  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
  ]
}


###################
## web rectangel-games
###################

module "prod_web_rectangle_games" {
  providers = {
    aws = aws.current
  }
  instance_count_min = 1
  source             = "../../modules/web"

  task_size_cpu    = 512
  task_size_memory = 1024

  app_env  = local.environment
  image    = "211125478834.dkr.ecr.sa-east-1.amazonaws.com/revengegames/web-rectangle-games:v1.0.76.1"
  app_name = "web-rectangle-games"

  role = aws_iam_role.prod_service

  env = {
    "NODE_ENV" : "production"
  }

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
      arn  = aws_lb_target_group.prod_web_rectangle_games.arn,
      port = 3000
    }]
  }

}
resource "aws_lb_target_group" "prod_web_rectangle_games" {
  name        = "${local.environment}-web-rectangle-games"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_networking.vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  tags = {
    Environment = local.environment
  }
}

resource "aws_lb_listener_rule" "prod_web_rectangle_games" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 331

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_web_rectangle_games.arn
  }

  condition {
    host_header {
      values = ["web.rectangle-games.com"]
    }
  }

  tags = {
    Name        = "web.rectangle-games.com"
    Environment = "${local.environment}"
  }
}
