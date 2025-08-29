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
    "aphrodite",
    "bierfest-delight",
    "bikini-babes",
    "chasing-leprechaun-coins",
    "common-assets",
    "common-assets-v3",
    "dragon-wonder",
    "empress-of-the-black-seas",
    "gates-of-kunlun",
    "gladiators",
    "god-of-fortune",
    "gold-seekers",
    "kawaii-neko",
    "legendary-el-toro",
    "longevity-dragon",
    "mahjong-fortune",
    "mahjong-legend",
    "mahjong-naga",
    "mayan-gold-hunt",
    "mega-wild-safari",
    "mermaid-treasure",
    "mochi-mochi",
    "mysteries-of-pandora",
    "pandora",
    "pawsome-xmas",
    "persian-gems",
    "pumpkin-night",
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
    "treasures-of-aztec-rewind",
    "treasures-of-aztec-two",
    "mkt"
  ])

  games_v3 = toset([
    "fortune-mouse",
    "fortune-ox",
    "fortune-dragon",
    "fortune-dragon-two",
    "dragon-hatch",
    "super-dragon-hatch",
    "fortune-tiger-2",
    "fortune-mouse-two",
    "fortune-ox-two",
    "fortune-tiger-two",
    "fortune-rabbit",
    "lucky-leprechaun-loot",
    "mermaids-bounty",
    "persian-jewels",
    "gates-of-olympus",
    "gates-of-olympus-1000",
    "sugar-rush",
  ])

  portals = toset([
    "lobby"
  ])

  static_routes = setunion(
    local.games_v2,
    local.games_v3,
  )
}

resource "aws_s3_object" "routes" {
  bucket = aws_s3_bucket.this.bucket
  key    = "routes.json"

  content_type = "application/json"
  content = jsonencode({
    http = {
      routers = { for name in local.static_routes :
        "${name}_sandbox" => {
          rule        = "Host(`${name}.sandbox.revenge-games.com`)"
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

# module "staging_service_router" {
#   source = "../../modules/service-traefik"
#   providers = {
#     aws = aws.current
#   }

#   app_env    = local.environment
#   config_url = "${aws_s3_bucket_website_configuration.this.website_endpoint}/routes.json"
#   role       = aws_iam_role.staging_service
#   network_configuration = {
#     region = "${local.region}"
#     vpc    = module.staging_networking.vpc
#     subnets = [
#       module.staging_networking.subnet_private_1.id,
#       module.staging_networking.subnet_private_2.id
#     ]
#     security_groups = [
#       module.staging_networking.vpc.default_security_group_id
#     ]
#     load_balancer_target_groups = [
#       aws_lb_target_group.staging_service_static_router
#     ]
#   }
# }

resource "cloudflare_record" "sites" {
  for_each = local.static_routes

  zone_id = data.cloudflare_zone.root.id
  name    = "${each.key}.sandbox"
  value   = module.sandbox_cloudfront.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = true
}
resource "cloudflare_record" "lobby" {
  zone_id = data.cloudflare_zone.root.id
  name    = "lobby.sandbox"
  value   = "dqiwis506b7a6.cloudfront.net"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "assets" {
  zone_id = data.cloudflare_zone.root.id
  name    = "assets.sandbox"
  value   = module.sandbox_cloudfront.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = true
}


resource "aws_lb_target_group" "staging_service_static_router" {
  name        = "${local.environment}-service-static-router"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.staging_networking.vpc.id
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

resource "aws_lb_listener_rule" "staging_static_routes" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 49999

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_static_router.arn
  }

  condition {
    host_header {
      values = [
        "*.${local.environment}.${local.root_domain}"
      ]
    }
  }

  tags = {
    Name        = "static.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "staging_static_routes_sandbox" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 49998

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_service_static_router.arn
  }

  condition {
    host_header {
      values = [
        "*.sandbox.${local.root_domain}"
      ]
    }
  }

  tags = {
    Name        = "static.${local.environment}.${local.root_domain}"
    Environment = "${local.environment}"
  }
}


resource "aws_lb_listener_rule" "sandbox_config_v2" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 49996

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      status_code  = 200
      message_body = jsonencode({
        commonassetsURL = "https://common-assets.sandbox.${local.root_domain}"
        envURL          = "https://api.sandbox.${local.root_domain}"
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
        "*.sandbox.${local.root_domain}"
      ]
    }
  }

  tags = {
    Name        = "config.json-v2"
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener_rule" "staging_config_v2" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 49997

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      status_code  = 200
      message_body = jsonencode({
        commonassetsURL = "https://common-assets.staging.${local.root_domain}"
        envURL          = "https://api.staging.${local.root_domain}"
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
        "*.staging.${local.root_domain}"
      ]
    }
  }

  tags = {
    Name        = "config.json-v2"
    Environment = "${local.environment}"
  }
}


resource "aws_lb_listener_rule" "sandbox_config_v3" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 49994

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      status_code  = 200
      message_body = jsonencode({
        commonassetsURL = "https://common-assets-v3.sandbox.${local.root_domain}"
        envURL          = "https://api.sandbox.${local.root_domain}"
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
        "dragon-hatch.*"
      ]
    }
  }

  tags = {
    Name        = "config.json-v3"
    Environment = "${local.environment}"
  }
}


resource "aws_lb_listener_rule" "sandbox_config_v3_2" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 49993

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      status_code  = 200
      message_body = jsonencode({
        commonassetsURL = "https://common-assets-v3.sandbox.${local.root_domain}"
        envURL          = "https://api.sandbox.${local.root_domain}"
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
        "super-dragon-hatch.*",
        "fortune-tiger-2.*"

      ]
    }
  }

  tags = {
    Name        = "config.json-v3"
    Environment = "${local.environment}"
  }
}


resource "aws_lb_listener_rule" "sandbox_env_configs" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 49995

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/javascript"
      status_code  = 200
      message_body = <<EOT
window._env_ = {
  WS_ENDPOINT: "wss://api.sandbox.${local.root_domain}/ws",
  GAME_CODE: "",
};
EOT
    }
  }

  condition {
    path_pattern {
      values = [
        "/env-config.*.js",
        "/env-config.js",
        "/*/env-config.*.js"
      ]
    }
  }

  condition {
    host_header {
      values = [
        "*.sandbox.${local.root_domain}",
        "*.sandbox.rectangle-games.com"
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
  priority     = 49990

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/javascript"
      status_code  = 200
      message_body = <<EOT
window._env_ = {
  WS_ENDPOINT: "wss://api.sandbox.revenge-games.com/ws",
  GAME_CODE: "fortune-dragon",
  BASE_URL:'https://api.sandbox.revenge-games.com',
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
        "fortune-dragon.*"
      ]
    }
  }

  tags = {
    Name        = "env-config.js"
    Environment = "${local.environment}"
  }
}
