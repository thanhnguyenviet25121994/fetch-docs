module "prd_eu_launcher" {
  source = "../../modules/launcher"

  alb_dns_name = aws_lb.prd_eu.dns_name

  app_env             = "prd_eu"
  app_name            = "launcher"
  app_domain          = "launcher.lnga-rg.com"
  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/12384ca0-ea63-4495-9397-027232c47c60"
  lambda_edge_arn     = "arn:aws:lambda:us-east-1:211125478834:function:prd-eu-launcher-edge-router:12"
}

resource "cloudflare_record" "launcher" {
  zone_id = data.cloudflare_zone.root.id
  name    = "launcher"
  type    = "CNAME"
  content = module.prd_eu_launcher.cloudfront_distribution_domain_name
  proxied = false

  allow_overwrite = true
}