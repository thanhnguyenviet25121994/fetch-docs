
module "staging_web_landing_page" {
  source = "../../modules/web-landing-page"
  providers = {
    aws = aws.current
  }

  app_env   = local.environment
  domain    = "sandbox.${local.rectangle_domain}"
  image     = "211125478834.dkr.ecr.ap-southeast-1.amazonaws.com/revengegames/web-landing-page:v1.0.81.1"
  value_dns = aws_lb.staging.dns_name
  app_dns   = "sandbox.${local.rectangle_domain}"
  role      = aws_iam_role.staging_service
  env = [{
    name  = "MAILER_SENDER_EMAIL",
    value = "do-not-reply@rectangle-games.com"
    },
    {
      name  = "MAILER_RECIPIENT_EMAILS",
      value = "contact@rectangle-games.com,dung.le@revenge.games,quy.nguyenn@revenge.games"
    },
    { name  = "AWS_REGION",
      value = "ap-southeast-1"
    }
  ]

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
    load_balancer = aws_lb.staging
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}

resource "cloudflare_record" "web_landing_page" {
  zone_id = data.cloudflare_zone.rectangle.id
  name    = "sandbox"
  content = aws_lb.staging.dns_name
  type    = "CNAME"
  proxied = true
}


###################
## web rectangel-games
###################

module "staging_web_rectangle_games" {
  providers = {
    aws = aws.current
  }
  instance_count_min = 1
  source             = "../../modules/web"

  task_size_cpu    = 512
  task_size_memory = 1024

  app_env  = local.environment
  image    = "211125478834.dkr.ecr.ap-northeast-1.amazonaws.com/revengegames/web-rectangle-games:v1.0.76.1"
  app_name = "web-rectangle-games"

  role = aws_iam_role.staging_service

  env = {
    "NODE_ENV" : "production"
  }

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
      arn  = aws_lb_target_group.staging_web_rectangle_games.arn,
      port = 3000
    }]
  }

}
resource "aws_lb_target_group" "staging_web_rectangle_games" {
  name        = "${local.environment}-web-rectangle-games"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.staging_networking.vpc.id
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

resource "aws_lb_listener_rule" "staging_web_rectangle_games" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 331

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_web_rectangle_games.arn
  }

  condition {
    host_header {
      values = ["web.sandbox.rectangle-games.com"]
    }
  }

  tags = {
    Name        = "web.sandbox.rectangle-games.com"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "web_rectangle_games" {
  zone_id = data.cloudflare_zone.rectangle.id
  name    = "web.sandbox"
  content = aws_lb.staging.dns_name
  type    = "CNAME"
  proxied = true
}