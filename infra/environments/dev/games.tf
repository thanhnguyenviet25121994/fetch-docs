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
    key = "index.html"
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
    # "bierfest-delight",
    "bikini-babes",
    "chasing-leprechaun-coins",
    "common-assets",
    "dragon-wonder",
    "empress-of-the-black-seas",
    "gates-of-kunlun",
    "gladiators",
    "kawaii-neko",
    "legendary-el-toro",
    "longevity-dragon",
    "mahjong-fortune",
    # "mahjong-legend",
    # "mahjong-naga",
    # "mayan-gold-hunt",
    # "mega-wild-safari",
    "mermaid-treasure",
    "mochi-mochi",
    "mysteries-of-pandora",
    # "pandora",
    "pawsome-xmas",
    "persian-gems",
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
    "treasures-of-aztec-rewind",
    "god-of-fortune",
    "gold-seekers",
    "treasures-of-aztec-two",
    "persian-jewels",
    "gates-of-olympus",
    "firebird-quest",
    "aphrodite-heart",
    "golden-year",
    "path-of-gods",
    "mighty-toro",
  ])

  cf_dev_gamev2 = toset([
    "wrath-of-zeus"
  ])

  games_v3 = toset([
    "common-assets-v3",
    "fortune-mouse",
    "fortune-dragon",
    "fortune-ox",
    "dragon-hatch",
    "super-dragon-hatch",
    "fortune-tiger",
    "fortune-tiger-2",
    "fortune-dragon-two",
    "fortune-mouse-two",
    "fortune-ox-two",
    "fortune-tiger-two",
    "fortune-rabbit",
    "lucky-leprechaun-loot",
    "mermaids-bounty",
    "sweet-bonanza",
    "swaggy-caramelo",
    "gates-of-olympus-1000",
    "sugar-rush",
    "diamond-rise",
    "sweet-bonanza-1000",
    "lucky-snake",
    "lucky-fox",
    "lucky-turtle",
    "lucky-duck",
    "solar-pong",
    "the-lone-fireball",
    "disco-fever",
    "magic-circus",
    "fiesta-blue",
    "rudolphs-gift",
    "realm-of-thunder",
    "iron-valor",
  ])

  portals = toset([
    "lobby",
    "assets",
    "mkt"
  ])

  static_routes = setunion(
    local.games_v2,
    local.games_v3,
    local.portals,
    local.cf_dev_gamev2,
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
          rule        = "Host(`${name}.dev.revenge-games.com`)"
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


resource "cloudflare_record" "games_v2" {
  for_each = local.games_v2

  zone_id = data.cloudflare_zone.root.id
  name    = "${each.key}.dev"
  content = module.dev_cloudfront.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = true
}
resource "cloudflare_record" "games_v3" {
  for_each = local.games_v3

  zone_id = data.cloudflare_zone.root.id
  name    = "${each.key}.dev"
  content = module.dev_cloudfront.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "lobby_portal" {

  zone_id = data.cloudflare_zone.root.id
  name    = "lobby.dev"
  value   = "d2ek2reg3frdx7.cloudfront.net"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "portal_launcher" {
  zone_id = data.cloudflare_zone.root.id
  name    = "launcher.${local.environment}.${local.root_domain}"
  content = module.dev_cloudfront.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}

resource "cloudflare_record" "assets_portal" {
  zone_id = data.cloudflare_zone.root.id
  name    = "assets.dev"
  value   = module.dev_cloudfront.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "dev_games_v2" {
  for_each = local.cf_dev_gamev2

  zone_id = data.cloudflare_zone.root.id
  name    = "${each.key}.dev"
  value   = module.dev_cloudfront.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = true
}

resource "aws_lb_target_group" "dev_service_static_router" {
  name        = "${local.environment}-service-static-router"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.dev_networking.vpc.id
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

# resource "aws_lb_listener_rule" "dev_static_routes" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 50000

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.dev_service_static_router.arn
#   }

#   condition {
#     host_header {
#       values = [
#         "*.${local.environment}.${local.root_domain}"
#       ]
#     }
#   }

#   tags = {
#     Name        = "static.${local.environment}.${local.root_domain}"
#     Environment = "${local.environment}"
#   }
# }

# resource "aws_lb_listener_rule" "env_config_v2" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 49999

#   action {
#     target_group_arn = aws_lb_target_group.dev_service_static_router.arn
#     type             = "fixed-response"

#     fixed_response {
#       content_type = "application/json"
#       status_code  = 200
#       message_body = jsonencode({
#         commonassetsURL = "https://common-assets.${local.environment}.${local.root_domain}"
#         envURL          = "https://api.${local.environment}.${local.root_domain}"
#       })
#     }
#   }

#   condition {
#     path_pattern {
#       values = [
#         "/config.json"
#       ]
#     }
#   }

#   tags = {
#     Name        = "config.json-v2"
#     Environment = "${local.environment}"
#   }
# }

# resource "aws_lb_listener_rule" "dev_config_v3" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 49998

#   action {
#     target_group_arn = aws_lb_target_group.dev_service_static_router.arn
#     type             = "fixed-response"

#     fixed_response {
#       content_type = "application/json"
#       status_code  = 200
#       message_body = jsonencode({
#         commonassetsURL = "https://common-assets-v3.${local.environment}.${local.root_domain}"
#         envURL          = "https://api.${local.environment}.${local.root_domain}"
#       })
#     }
#   }

#   condition {
#     path_pattern {
#       values = [
#         "/config.json"
#       ]
#     }
#   }

#   condition {
#     host_header {
#       values = [
#         "fortune-mouse.*",
#         "fortune-ox.*",
#         "fortune-dragon.*",
#         "dragon-hatch.*",
#       ]
#     }
#   }

#   tags = {
#     Name        = "config.json-v3"
#     Environment = "${local.environment}"
#   }
# }

# resource "aws_lb_listener_rule" "dev_config_v3_2" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 49985

#   action {
#     target_group_arn = aws_lb_target_group.dev_service_static_router.arn
#     type             = "fixed-response"

#     fixed_response {
#       content_type = "application/json"
#       status_code  = 200
#       message_body = jsonencode({
#         commonassetsURL = "https://common-assets-v3.${local.environment}.${local.root_domain}"
#         envURL          = "https://api.${local.environment}.${local.root_domain}"
#       })
#     }
#   }

#   condition {
#     path_pattern {
#       values = [
#         "/config.json"
#       ]
#     }
#   }

#   condition {
#     host_header {
#       values = [
#         "fortune-tiger.*",
#         "dragon-hatch-2.*",
#       ]
#     }
#   }

#   tags = {
#     Name        = "config.json-v3"
#     Environment = "${local.environment}"
#   }
# }

# resource "aws_lb_listener_rule" "env_configs" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 49997

#   action {
#     target_group_arn = aws_lb_target_group.dev_service_static_router.arn
#     type             = "fixed-response"

#     fixed_response {
#       content_type = "application/javascript"
#       status_code  = 200
#       message_body = <<EOT
# window._env_ = {
#   WS_ENDPOINT: "wss://api.${local.environment}.${local.root_domain}/ws",
#   GAME_CODE: "",
# };
# EOT
#     }
#   }

#   condition {
#     path_pattern {
#       values = [
#         "/env-config.*.js",
#         "/env-config.js"
#       ]
#     }
#   }

#   tags = {
#     Name        = "env-config.js"
#     Environment = "${local.environment}"
#   }
# }

# resource "aws_lb_listener_rule" "env_configs_new" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 49996

#   action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "application/javascript"
#       status_code  = 200
#       message_body = <<EOT
# window._env_ = {
#   WS_ENDPOINT: "wss://api.dev.revenge-games.com/ws",
#   GAME_CODE: "fortune-dragon",
#   BASE_URL:'https://api.dev.revenge-games.com',
#   BET_URL: "bets",
#   TOTAL_BET_URL: "total-bets",
# };
# EOT
#     }
#   }

#   condition {
#     path_pattern {
#       values = [
#         "/env-config.js"
#       ]
#     }
#   }

#   condition {
#     host_header {
#       values = [
#         "fortune-dragon.*",
#       ]
#     }
#   }

#   tags = {
#     Name        = "env-config.js"
#     Environment = "${local.environment}"
#   }
# }

# module "prod_cloudfront" {
#   source = "../../modules/cloudfront"

#   app_env           = local.environment
#   root_domain       = local.root_domain
#   origin_domain_elb = aws_lb.prod.dns_name
# }
