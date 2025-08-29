#######################
#### as.rg-lgna.com: AllStar Games


module "prod_allstar_game" {
  source = "../../modules/game-g-prod"

  alb_dns_name = aws_lb.prod.dns_name

  app_env             = local.environment
  app_name            = "allstar_game"
  app_domain          = "as.rg-lgna.com"
  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/ed6127af-7d88-4f93-a1a9-ad044a5155b6"
  lambda_edge_arn     = "arn:aws:lambda:us-east-1:211125478834:function:prod-astar-edge-router:5"
}

resource "cloudflare_record" "prod_allstar_game" {
  zone_id = data.cloudflare_zone.root.id
  name    = "as"
  content = module.prod_allstar_game.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}




#######################
#### rectangle_game

module "prod_rectangle_games" {
  source = "../../modules/game-g-prod"

  alb_dns_name = aws_lb.prod.dns_name

  app_env             = local.environment
  app_name            = "rectangle_game"
  app_domain          = "rc.rg-lgna.com"
  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/ed6127af-7d88-4f93-a1a9-ad044a5155b6"
  lambda_edge_arn     = "arn:aws:lambda:us-east-1:211125478834:function:prod-rectangle-edge-router:7"
}

resource "cloudflare_record" "prod_rectangle_games" {
  zone_id = data.cloudflare_zone.root.id
  name    = "rc"
  content = module.prod_rectangle_games.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}


#######################
#### revenge games

module "prod_revenge_games" {
  source = "../../modules/game-rg-prod"

  alb_dns_name = aws_lb.prod.dns_name

  app_env             = local.environment
  app_name            = "revenge_game"
  app_domain          = "rg.rg-lgna.com"
  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/ed6127af-7d88-4f93-a1a9-ad044a5155b6"
  lambda_edge_arn     = "arn:aws:lambda:us-east-1:211125478834:function:prod-rg-edge-router:2"
}

resource "cloudflare_record" "prod_revenge_games" {
  zone_id = data.cloudflare_zone.root.id
  name    = "rg"
  content = module.prod_revenge_games.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = true
}

#######################
#### launcher

module "prod_launcher" {
  source = "../../modules/launcher"

  alb_dns_name = aws_lb.prod.dns_name

  app_env             = "prod"
  app_name            = "launcher"
  app_domain          = "launcher.rg-lgna.com"
  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/ed6127af-7d88-4f93-a1a9-ad044a5155b6"
  lambda_edge_arn     = "arn:aws:lambda:us-east-1:211125478834:function:prod-launcher-edge-router:12"
}

resource "cloudflare_record" "prod_launcher" {
  zone_id = data.cloudflare_zone.root.id
  name    = "launcher"
  content = module.prod_launcher.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}

#######################
#### launcher allstar

module "prod_launcher_astar" {
  source = "../../modules/launcher"

  alb_dns_name = aws_lb.prod.dns_name

  app_env             = "prod"
  app_name            = "launcher"
  app_domain          = "launcher.all-star.games"
  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/874af26d-12d2-434f-9218-d67d0f9636b5"
  lambda_edge_arn     = "arn:aws:lambda:us-east-1:211125478834:function:prod-launcher-edge-router:12"
}


#######################
#### launcher rectangle

module "prod_launcher_rectangle" {
  source = "../../modules/launcher"

  alb_dns_name = aws_lb.prod.dns_name

  app_env             = "prod"
  app_name            = "launcher"
  app_domain          = "launcher.rectangle-games.com"
  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/13c8677d-ec0b-4767-9cc6-c10d113b9ad3"
  lambda_edge_arn     = "arn:aws:lambda:us-east-1:211125478834:function:prod-launcher-edge-router:12"
}