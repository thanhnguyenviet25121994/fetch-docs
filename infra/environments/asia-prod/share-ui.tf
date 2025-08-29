module "prod_asia_share_ui_game_client" {
  source = "../../modules/share-ui-game-client"
  providers = {
    aws = aws.current
  }

  app_env   = local.environment
  domain    = ["uig.${local.rg_domain}"]
  image     = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/share-ui-game-client:v1.0.848.1"
  value_dns = aws_lb.prod_asia.dns_name
  app_dns   = "uig.${local.rg_domain}"
  role      = aws_iam_role.prod_asia_service
  env = [
    {
      name  = "NEXT_PUBLIC_API_BASE_URL",
      value = "https://apig.${local.rg_domain}"
    },
    {
      name  = "API_BASE_URL",
      value = "https://apig.${local.rg_domain}"
    },
    {
      name  = "CACHE_REVALIDATE_IN_SECONDS",
      value = 900
    },
  ]

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
    load_balancer = aws_lb.prod_asia
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
  ]
}

resource "cloudflare_record" "prod_asia_share_ui_game_client" {
  zone_id = data.cloudflare_zone.rg.id
  name    = "uig"
  content = module.global_accelerator.dns_name
  type    = "CNAME"
  proxied = true
}


resource "aws_lb_listener_rule" "share_ui_sgc" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 39000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_game_client.arn
  }

  condition {
    host_header {
      values = ["uig.rg-lgna.com"]
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



