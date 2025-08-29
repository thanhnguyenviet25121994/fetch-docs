module "mkt_share_ui_game_client" {
  source = "../../modules/share-ui-game-client"
  providers = {
    aws = aws.current
  }

  app_env   = local.environment
  domain    = ["share-ui-game-client-mkt.${local.root_domain}"]
  image     = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/share-ui-game-client:v1.0.254.1"
  value_dns = aws_lb.mkt.dns_name
  app_dns   = "share-ui-game-client-mkt.${local.root_domain}"
  role      = aws_iam_role.mkt_service
  env = [
    {
      name  = "NEXT_PUBLIC_API_BASE_URL",
      value = "https://mkt.rg-lgna.com"
    },
    {
      name  = "API_BASE_URL",
      value = "https://mkt.rg-lgna.com"
    },
    {
      name  = "CACHE_REVALIDATE_IN_SECONDS",
      value = 900
    },
  ]

  network_configuration = {
    region = "${local.region}"
    vpc    = module.mkt_networking.vpc
    subnets = [
      module.mkt_networking.subnet_private_1.id,
      module.mkt_networking.subnet_private_2.id
    ]
    security_groups = [
      module.mkt_networking.vpc.default_security_group_id
    ]
    load_balancer = aws_lb.mkt
  }

  depends_on = [
    aws_iam_role.mkt_service,
    aws_iam_role_policy.mkt_service_policy,
  ]
}

resource "cloudflare_record" "mkt_share_ui_game_client" {
  zone_id = data.cloudflare_zone.root.id
  name    = "share-ui-game-client-mkt"
  content = aws_lb.mkt.dns_name
  type    = "CNAME"
  proxied = true
}


resource "aws_lb_listener_rule" "share_ui_sgc" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 39000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mkt_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        "share-ui-game-client-mkt.rg-lgna.com",
        "uig.mkt.rg-lgna.com"
      ]
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
