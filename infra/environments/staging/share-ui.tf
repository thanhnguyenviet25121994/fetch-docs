module "staging_share_ui_game_client" {
  source = "../../modules/share-ui-game-client"
  providers = {
    aws = aws.current
  }

  app_env   = local.environment
  domain    = ["share-ui-game-client.sandbox.${local.root_domain}"]
  image     = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/share-ui-game-client:v1.0.1308.1"
  value_dns = aws_lb.staging.dns_name
  app_dns   = "share-ui-game-client.sandbox.${local.root_domain}"
  role      = aws_iam_role.staging_service
  env = [
    {
      name  = "API_BASE_URL",
      value = "https://api.sandbox.revenge-games.com"
    },
    {
      name  = "CACHE_REVALIDATE_IN_SECONDS",
      value = 900
    },
    {
      name  = "PROMO_WS_BASE_URL",
      value = "wss://promotion.sandbox.revenge-games.com"
    },
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

resource "cloudflare_record" "staging_share_ui_game_client" {
  zone_id = data.cloudflare_zone.root.id
  name    = "share-ui-game-client.sandbox"
  content = aws_lb.staging.dns_name
  type    = "CNAME"
  proxied = true
}

resource "aws_lb_listener_rule" "share_ui_sgc" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 39000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_game_client.arn
  }

  condition {
    host_header {
      values = ["share-ui-game-client.sandbox.revenge-games.com"]
    }
  }
  condition {
    path_pattern {
      values = [
        "/api/*"
      ]
    }
  }

  tags = {
    Name        = "share-ui-sgc"
    Environment = "${local.environment}"
  }
}
