module "prod_share_ui_game_client" {
  source = "../../modules/share-ui-game-client"
  providers = {
    aws = aws.current
  }

  app_env   = local.environment
  domain    = ["share-ui-game-client.${local.root_domain}", "uig.rg-lgna.com"]
  image     = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/share-ui-game-client:v1.0.254.1"
  value_dns = aws_lb.prod.dns_name
  app_dns   = "share-ui-game-client.${local.root_domain}"
  role      = aws_iam_role.prod_service
  env = [
    {
      name  = "NEXT_PUBLIC_API_BASE_URL",
      value = "https://api.rg-lgna.com"
    },
    {
      name  = "API_BASE_URL",
      value = "https://api.${local.root_domain}"
    },
    {
      name  = "CACHE_REVALIDATE_IN_SECONDS",
      value = 900
    },
  ]
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prod_networking.vpc
    subnets = [
      module.prod_networking.subnet_private_1.id,
      module.prod_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prod_networking.vpc.default_security_group_id
    ]
    load_balancer = aws_lb.prod
  }

  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
  ]
}

resource "cloudflare_record" "prod_share_ui_game_client" {
  zone_id = data.cloudflare_zone.root.id
  name    = "share-ui-game-client"
  content = aws_lb.prod.dns_name
  type    = "CNAME"
  proxied = true
}


resource "aws_lb_listener_rule" "share_ui_sgc" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 39000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_game_client.arn
  }

  condition {
    host_header {
      values = [
        "share-ui-game-client.rg-lgna.com",
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
