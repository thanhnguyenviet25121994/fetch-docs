module "dev_share_ui_game_client" {
  source = "../../modules/share-ui-game-client"
  providers = {
    aws = aws.current
  }

  app_env   = local.environment
  domain    = ["share-ui-game-client.${local.environment}.${local.root_domain}"]
  image     = "211125478834.dkr.ecr.ap-southeast-1.amazonaws.com/revengegames/share-ui-game-client:v1.0.1191.1"
  value_dns = aws_lb.dev.dns_name
  app_dns   = "share-ui-game-client.${local.environment}.${local.root_domain}"
  role      = aws_iam_role.dev_service
  env = [
    {
      name  = "API_BASE_URL",
      value = "https://api.${local.environment}.${local.root_domain}"
    },
    {
      name  = "CACHE_REVALIDATE_IN_SECONDS",
      value = 900
    },
    {
      name  = "PROMO_WS_BASE_URL",
      value = "wss://promotion.dev.revenge-games.com"
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

resource "cloudflare_record" "dev_share_ui_game_client" {
  zone_id = data.cloudflare_zone.root.id
  name    = "share-ui-game-client.dev"
  content = aws_lb.dev.dns_name
  type    = "CNAME"
  proxied = true
}



resource "aws_lb_listener_rule" "share_ui_sgc" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 39000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_game_client.arn
  }

  condition {
    host_header {
      values = ["share-ui-game-client.dev.revenge-games.com"]
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


