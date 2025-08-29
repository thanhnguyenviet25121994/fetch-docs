data "aws_secretsmanager_secret" "dev_operator_demo_db" {
  name = "${local.environment}/operator-demo/db"
}

module "dev_operator_demo" {
  source = "../../modules/new-operator-demo"
  providers = {
    aws = aws.current
  }

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-operator-demo-kotlin:${local.operator_demo_version}"
  db = {
    endpoint    = aws_rds_cluster.dev_main.endpoint
    credentials = data.aws_secretsmanager_secret.dev_operator_demo_db
    name        = "operator_demo"
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
      arn  = aws_lb_target_group.dev_operator_demo.arn,
      port = 9400
    }]
  }

  depends_on = [
    aws_iam_role.dev_service,
    aws_iam_role_policy.dev_service_policy,
  ]
}

// TODO: define the zone here instead of inside the module
data "aws_route53_zone" "private" {
  name   = "revenge-games.dev"
  vpc_id = module.dev_networking.vpc.id
}

resource "aws_route53_record" "operator_demo" {
  zone_id = data.aws_route53_zone.private.id
  name    = "operator-demo"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_lb.dev.dns_name]
}

resource "aws_lb_target_group" "dev_operator_demo" {
  name        = "${local.environment}-operator-demo"
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

resource "aws_lb_listener_rule" "dev_operator_demo" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_operator_demo.arn
  }

  condition {
    host_header {
      values = ["operator-demo.*"]
    }
  }

  tags = {
    Name        = "operator-demo.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "cloudflare_record" "demo" {
  zone_id = data.cloudflare_zone.root.id
  name    = "operator-demo.${local.environment}"
  value   = aws_lb.dev.dns_name
  type    = "CNAME"
  proxied = true
}
