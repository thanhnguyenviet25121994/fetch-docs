module "prod_asia_launcher" {
  source              = "../../modules/launcher"
  alb_dns_name        = aws_lb.prod_asia.dns_name
  app_env             = "prod_asia"
  app_name            = "launcher"
  app_domain          = "launcher.${local.root_domain}"
  acm_certificate_arn = module.prod_acm.acm_certificate_arn
  lambda_edge_arn     = "arn:aws:lambda:us-east-1:211125478834:function:prod-asia-launcher-edge-router:1"
}

resource "cloudflare_record" "launcher" {
  zone_id = data.cloudflare_zone.root.id
  name    = "launcher"
  type    = "CNAME"
  content = module.prod_asia_launcher.cloudfront_distribution_domain_name
  proxied = false

  allow_overwrite = true
}