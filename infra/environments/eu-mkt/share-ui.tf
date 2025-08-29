module "mkt_eu_share_ui_game_client" {
  source = "../../modules/share-ui-game-client"
  providers = {
    aws = aws.current
  }

  app_env   = local.environment
  domain    = ["share-ui-game-client.mkt.${local.root_domain}"]
  image     = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/share-ui-game-client:v1.0.0.1"
  value_dns = aws_lb.mkt_eu.dns_name
  app_dns   = "share-ui-game-client.mkt.${local.root_domain}"
  role      = aws_iam_role.mkt_eu_service
  env = [
    {
      name  = "API_BASE_URL",
      value = "https://api.mkt.${local.root_domain}"
    },
    {
      name  = "CACHE_REVALIDATE_IN_SECONDS",
      value = 900
    },
  ]

  network_configuration = {
    region = "${local.region}"
    vpc    = module.mkt_eu_networking.vpc
    subnets = [
      module.mkt_eu_networking.subnet_private_1.id,
      module.mkt_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.mkt_eu_networking.vpc.default_security_group_id
    ]
    load_balancer = aws_lb.mkt_eu
  }

  depends_on = [
    aws_iam_role.mkt_eu_service,
    aws_iam_role_policy.mkt_eu_service_policy,
  ]
}

resource "cloudflare_record" "mkt_eu_share_ui_game_client" {
  zone_id = data.cloudflare_zone.root.id
  name    = "share-ui-game-client.mkt"
  content = aws_lb.mkt_eu.dns_name
  type    = "CNAME"
  proxied = true
}


resource "aws_lb_listener_rule" "share_ui_sgc" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 39000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mkt_eu_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        "share-ui-game-client.mkt.lnga-rg.com",
      "uig.mkt.rg-lgna.com"]
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
