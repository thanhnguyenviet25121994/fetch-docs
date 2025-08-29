
module "mkt_portal_bo" {
  source = "../../modules/portal-bo"

  app_env             = local.environment
  app_domain          = "mkt-bo.${local.root_domain}"
  app_name            = "bo"
  alb_dns_name        = aws_lb.mkt.dns_name
  lambda_edge_arn     = "arn:aws:lambda:us-east-1:211125478834:function:bo-mkt-edge-router:1"
  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/ed6127af-7d88-4f93-a1a9-ad044a5155b6"
}

resource "cloudflare_record" "mkt_portal_bo" {
  zone_id = data.cloudflare_zone.root.id
  name    = "mkt-bo"
  content = module.mkt_portal_bo.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}