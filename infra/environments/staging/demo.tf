data "aws_secretsmanager_secret" "staging_operator_demo_db" {
  name = "${local.environment}/operator-demo/db"
}

module "staging_operator_demo" {
  source = "../../modules/operator-demo"
  providers = {
    aws = aws.current
  }

  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-operator-demo-kotlin:${local.operator_demo_version}"
  db = {
    endpoint    = aws_rds_cluster.staging_main.endpoint
    credentials = data.aws_secretsmanager_secret.staging_operator_demo_db
    name        = "operator_demo"
  }

  role = aws_iam_role.staging_service
  network_configuration = {
    region = local.region
    vpc    = module.staging_networking.vpc
    subnets = [
      module.staging_networking.subnet_private_1.id,
      module.staging_networking.subnet_private_2.id
    ]
    security_groups = [
      module.staging_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.staging_operator_demo.arn,
      port = 9400
    }]
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}

resource "aws_lb_target_group" "staging_operator_demo" {
  name        = "${local.environment}-operator-demo"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.staging_networking.vpc.id
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

resource "aws_lb_listener_rule" "staging_operator_demo" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_operator_demo.arn
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

resource "cloudflare_record" "staging_operator_demo" {
  zone_id = data.cloudflare_zone.root.id
  name    = "operator-demo.sandbox"
  value   = aws_lb.staging.dns_name
  type    = "CNAME"
  proxied = true
}
