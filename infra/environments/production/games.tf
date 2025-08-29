resource "aws_s3_bucket" "this" {
  bucket = "revengegames-${local.environment}"

  tags = {
    Name        = "revengegames-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.this.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.public
  ]
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_allow_public_access.json
}

locals {
  games_v2 = toset([
    "amazing-circus",
    "chasing-leprechaun-coins",
    "bikini-babes",
    "aphrodite",
    # "bierfest-delight",
    "dragon-wonder",
    # "mayan-gold-hunt",
    # "pumpkin-night",
    "queen-of-aztec",
    "rave-on",
    "run-pug-run",
    "sakura-neko",
    "samba-fiesta",
    "sanguo",
    "sexy-christmas-sirens",
    "spring-harvest",
    "stallion-princess",
    "steampunk-reloaded",
    "sugary-bonanza",
    "super-phoenix",
    "temple-of-gods",
    "wild-west-saloon",
    "wrath-of-zeus",
    # "mahjong-naga",
    "persian-gems",
    "pawsome-xmas",
    # "pandora",
    "mysteries-of-pandora",
    "mochi-mochi",
    "mermaid-treasure",
    # "mega-wild-safari",
    # "mahjong-legend",
    "mahjong-fortune",
    "longevity-dragon",
    "legendary-el-toro",
    "kawaii-neko",
    "gold-seekers",
    "god-of-fortune",
    "gladiators",
    "gates-of-kunlun",
    "empress-of-the-black-seas",
    "treasures-of-aztec-rewind",
    "treasures-of-aztec-two",
  ])

  games_v3 = toset([
    "fortune-mouse",
    "fortune-dragon",
    "fortune-ox",
    "dragon-hatch",
    "super-dragon-hatch",
    "fortune-tiger-2",
    "fortune-tiger-two",
    "fortune-ox-two",
    "fortune-dragon-two",
    # "treasures-of-aztec-two",
    # "treasures-of-aztec-rewind",
    "fortune-mouse-two",
    "fortune-rabbit",
    "lucky-leprechaun-loot",
    "mermaids-bounty",
    "persian-jewels",
    "gates-of-olympus",
    "gates-of-olympus-1000"
  ])

  portals = toset([
    "lobby",
    "assets"
  ])
  common_assets_v3 = toset([
    "common-assets-v3"
  ])
  common_assets_v2 = toset([
    "common-assets"
  ])

  static_routes = setunion(
    local.games_v2,
    local.games_v3,
    local.portals,
    local.common_assets_v3,
    local.common_assets_v2
  )
}

resource "aws_s3_object" "routes" {
  bucket = aws_s3_bucket.this.bucket
  key    = "routes.json"

  content_type = "application/json"
  content = jsonencode({
    http = {
      routers = { for name in local.static_routes :
        name => {
          rule        = "Host(`${name}.${local.root_domain}`)"
          service     = "static"
          middlewares = [name, "addHostHeader"]
        }
      }
      middlewares = merge({
        addHostHeader = {
          headers = {
            customRequestHeaders = {
              Host = aws_s3_bucket_website_configuration.this.website_endpoint
            }
          }
        }
        }, {
        for name in local.static_routes :
        name => {
          addPrefix = {
            prefix = "/${name}"
          }
        }
      })
      services = {
        static = {
          loadBalancer = {
            servers = [{
              url = "http://${aws_s3_bucket_website_configuration.this.website_endpoint}"
            }]
            passHostHeader = false
          }
        }
      }
    }
  })
}

module "prod_service_router" {
  source = "../../modules/service-traefik"
  providers = {
    aws = aws.current
  }

  desired_count = 2

  app_env    = local.environment
  config_url = "${aws_s3_bucket_website_configuration.this.website_endpoint}/routes.json"
  role       = aws_iam_role.prod_service

  task_cpu = 512
  task_mem = 1024
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
    load_balancer_target_groups = [
      aws_lb_target_group.prod_service_static_router
    ]
  }
}

resource "cloudflare_record" "sites_games_v2" {
  for_each = local.games_v2

  zone_id = data.cloudflare_zone.root.id
  name    = each.key
  content = "d1d11sb0demcq8.cloudfront.net"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "sites_games_v3" {
  for_each = local.games_v3

  zone_id = data.cloudflare_zone.root.id
  name    = each.key
  content = "d1d11sb0demcq8.cloudfront.net"
  type    = "CNAME"
  # FIXME: experimenting enable CloudFlare for one game
  proxied = true
}

resource "cloudflare_record" "common_assets_v3" {
  for_each = local.common_assets_v3

  zone_id = data.cloudflare_zone.root.id
  name    = each.key
  content = "d1d11sb0demcq8.cloudfront.net"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "common_assets_v2" {
  for_each = local.common_assets_v2

  zone_id = data.cloudflare_zone.root.id
  name    = each.key
  content = "d1d11sb0demcq8.cloudfront.net"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "assets" {
  zone_id = data.cloudflare_zone.root.id
  name    = "assets.${local.root_domain}"
  content = "d1d11sb0demcq8.cloudfront.net"
  type    = "CNAME"
  proxied = true
}

resource "aws_lb_target_group" "prod_service_static_router" {
  name        = "${local.environment}-service-static-router"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_networking.vpc.id
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

resource "aws_lb_listener_rule" "prod_static_routes" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 50000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_static_router.arn
  }

  condition {
    host_header {
      values = [
        "*.${local.root_domain}"
      ]
    }
  }

  tags = {
    Name        = "static.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "prod_config_v2" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 49999

  action {
    target_group_arn = aws_lb_target_group.prod_service_static_router.arn
    type             = "fixed-response"

    fixed_response {
      content_type = "application/json"
      status_code  = 200
      message_body = jsonencode({
        commonassetsURL = "https://common-assets.${local.root_domain}"
        envURL          = "https://api.${local.root_domain}"
      })
    }
  }

  condition {
    path_pattern {
      values = [
        "/config.json"
      ]
    }
  }

  tags = {
    Name        = "config.json-v2"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "prod_config_v3" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 49998

  action {
    target_group_arn = aws_lb_target_group.prod_service_static_router.arn
    type             = "fixed-response"

    fixed_response {
      content_type = "application/json"
      status_code  = 200
      message_body = jsonencode({
        commonassetsURL = "https://common-assets-v3.${local.root_domain}"
        envURL          = "https://api.${local.root_domain}"
      })
    }
  }

  condition {
    path_pattern {
      values = [
        "/config.json"
      ]
    }
  }

  condition {
    host_header {
      values = [
        "fortune-mouse.*",
        "fortune-ox.*",
        "fortune-dragon.*",
        "dragon-hatch.*",
      ]
    }
  }

  tags = {
    Name        = "config.json-v3"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "env_configs" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 49997

  action {
    target_group_arn = aws_lb_target_group.prod_service_static_router.arn
    type             = "fixed-response"

    fixed_response {
      content_type = "application/javascript"
      status_code  = 200
      message_body = <<EOT
window._env_ = {
  WS_ENDPOINT: "wss://api.${local.root_domain}/ws",
  GAME_CODE: "",
};
EOT
    }
  }

  condition {
    path_pattern {
      values = [
        "/env-config.*.js",
        "/env-config.js"
      ]
    }
  }

  tags = {
    Name        = "env-config.js"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "env_configs_new" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 49996

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/javascript"
      status_code  = 200
      message_body = <<EOT
window._env_ = {
  WS_ENDPOINT: "wss://api.rg-lgna.com/ws",
  GAME_CODE: "fortune-dragon",
  BASE_URL:'https://api.rg-lgna.com',
  BET_URL: "bets",
  TOTAL_BET_URL: "total-bets",
};
EOT
    }
  }

  condition {
    path_pattern {
      values = [
        "/env-config.js"
      ]
    }
  }

  condition {
    host_header {
      values = [
        "fortune-dragon.*",
      ]
    }
  }

  tags = {
    Name        = "env-config.js"
    Environment = "${local.environment}"
  }
}

module "prod_cloudfront" {
  source = "../../modules/cloudfront"

  app_env                    = local.environment
  root_domain                = local.root_domain
  origin_domain_elb          = aws_lb.prod.dns_name
  lambda_arn                 = "arn:aws:lambda:us-east-1:211125478834:function:edge-router:41"
  lambda_arn_staging         = "arn:aws:lambda:us-east-1:211125478834:function:edge-router:41"
  origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"

  s3_website_endpoint = aws_s3_bucket_website_configuration.this.website_endpoint
}
