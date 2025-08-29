

###################
## game-ui
###################

module "dev_game_ui" {
  providers = {
    aws = aws.current
  }
  instance_count_min = 0
  source             = "../../modules/game-ui"

  task_size_cpu    = 512
  task_size_memory = 1024

  app_env  = local.environment
  image    = "211125478834.dkr.ecr.ap-southeast-1.amazonaws.com/revengegames/game-ui:v1.0.4.1"
  app_name = "game-ui"

  role = aws_iam_role.dev_service

  env = {
    BASE_URL = "https://rc.dev.revenge-games.com",
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
      arn  = aws_lb_target_group.dev_game_ui.arn,
      port = 8080
    }]
  }

}
resource "aws_lb_target_group" "dev_game_ui" {
  name        = "${local.environment}-game-ui"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  tags = {
    Environment = local.environment
  }
}

resource "aws_lb_listener_rule" "dev_game_ui" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 3111

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_game_ui.arn
  }

  condition {
    host_header {
      values = ["game-ui.dev.${local.root_domain}"]
    }
  }

  tags = {
    Name        = "game-ui.dev.${local.root_domain}"
    Environment = "${local.environment}"
  }
}


resource "cloudflare_record" "game_ui" {
  zone_id = data.cloudflare_zone.root.id
  name    = "game-ui.dev"
  content = aws_lb.dev.dns_name
  type    = "CNAME"
  proxied = true
}