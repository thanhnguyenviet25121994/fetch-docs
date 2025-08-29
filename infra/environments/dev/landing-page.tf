module "dev_web_landing_page" {
  source = "../../modules/web-landing-page"
  providers = {
    aws = aws.current
  }

  app_env   = local.environment
  domain    = "${local.environment}.${local.rectangle_domain}"
  image     = "211125478834.dkr.ecr.ap-southeast-1.amazonaws.com/revengegames/web-landing-page:v1.0.115.1"
  value_dns = aws_lb.dev.dns_name
  app_dns   = "${local.environment}.${local.rectangle_domain}"
  role      = aws_iam_role.dev_service
  env = [{
    name  = "MAILER_SENDER_EMAIL",
    value = "do-not-reply@rectangle-games.com"
    },
    {
      name  = "MAILER_RECIPIENT_EMAILS",
      value = "contact@rectangle-games.com,dung.le@revenge.games,quy.nguyenn@revenge.games"
    },
  ]

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
    load_balancer = aws_lb.dev
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}

resource "cloudflare_record" "web_landing_page" {
  zone_id = data.cloudflare_zone.rectangle.id
  name    = local.environment
  content = aws_lb.dev.dns_name
  type    = "CNAME"
  proxied = true
}





###################
## web renvenge-games
###################

module "dev_web_revenge_games" {
  providers = {
    aws = aws.current
  }
  instance_count_min = 1
  source             = "../../modules/web"

  task_size_cpu    = 1024
  task_size_memory = 2048

  app_env  = local.environment
  image    = "211125478834.dkr.ecr.ap-southeast-1.amazonaws.com/revengegames/web-revenge-games:v1.0.3.1"
  app_name = "web-revenge-games"

  role = aws_iam_role.dev_service

  env = {
    MAILER_SENDER_EMAIL     = "do-not-reply@revenge-games.com",
    MAILER_RECIPIENT_EMAILS = "dung.le@revenge.games,quy.nguyenn@revenge.games",
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
      arn  = aws_lb_target_group.dev_web_revenge_games.arn,
      port = 3000
    }]
  }

}
resource "aws_lb_target_group" "dev_web_revenge_games" {
  name        = "${local.environment}-web-revenge-games"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

resource "aws_lb_listener_rule" "dev_web_revenge_games" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 309

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_web_revenge_games.arn
  }

  condition {
    host_header {
      values = ["dev.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "dev.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "web_revenge_games" {
  zone_id = data.cloudflare_zone.root.id
  name    = local.environment
  content = aws_lb.dev.dns_name
  type    = "CNAME"
  proxied = true
}


###################
## web rectangel-games
###################

module "dev_web_rectangle_games" {
  providers = {
    aws = aws.current
  }
  instance_count_min = 1
  source             = "../../modules/web"

  task_size_cpu    = 512
  task_size_memory = 1024

  app_env  = local.environment
  image    = "211125478834.dkr.ecr.ap-southeast-1.amazonaws.com/revengegames/web-rectangle-games:latest"
  app_name = "web-rectangle-games"

  role = aws_iam_role.dev_service

  env = {
    # MAILER_SENDER_EMAIL     = "do-not-reply@revenge-games.com",
    # MAILER_RECIPIENT_EMAILS = "dung.le@revenge.games,quy.nguyenn@revenge.games",
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
      arn  = aws_lb_target_group.dev_web_rectangle_games.arn,
      port = 3000
    }]
  }

}
resource "aws_lb_target_group" "dev_web_rectangle_games" {
  name        = "${local.environment}-web-rectangle-games"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

resource "aws_lb_listener_rule" "dev_web_rectangle_games" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 331

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_web_rectangle_games.arn
  }

  condition {
    host_header {
      values = ["web.dev.rectangle-games.com"]
    }
  }

  tags = {
    Name        = "web.dev.rectangle-games.com"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "web_rectangle_games" {
  zone_id = data.cloudflare_zone.root.id
  name    = "web.${local.environment}"
  content = aws_lb.dev.dns_name
  type    = "CNAME"
  proxied = true
}