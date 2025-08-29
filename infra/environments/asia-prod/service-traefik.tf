module "prod_asia_service_traefik" {
  source = "../../modules/service-traefik-new"
  providers = {
    aws = aws.current
  }

  app_env = local.environment
  image   = "traefik:v3.4.4"
  role    = aws_iam_role.prod_asia_service
  # clusters = module.prod_asia_service_game_client.get_aws_ecs_cluster.name
  clusters = "prod-asia-service-game-client-test"
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prod_asia_networking.vpc
    subnets = [
      module.prod_asia_networking.subnet_private_1.id,
      module.prod_asia_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prod_asia_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_asia_service_traefik.arn,
      port = 80
      }
    ]
  }
}

resource "aws_lb_target_group" "prod_asia_service_traefik" {
  name        = "${local.environment}-service-traefik"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_asia_networking.vpc.id
  target_type = "ip"

  health_check {
    path                = "/ping"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  tags = {
    Environment = local.environment
  }
}

resource "aws_lb_listener_rule" "prod_asia_service_traefik" {
  listener_arn = aws_lb_listener.http_private2.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_traefik.arn
  }

  condition {
    host_header {
      values = ["traefik.revenge-games.global", "sgctest.revenge-games.global"]
    }
  }

  tags = {
    Name        = "traefik"
    Environment = "${local.environment}"
  }
}