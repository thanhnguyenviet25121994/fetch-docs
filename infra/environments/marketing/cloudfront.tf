module "mkt_cloudfront" {
  source = "../../modules/cloudfront-mkt"

  app_env                    = local.environment
  root_domain                = local.root_domain
  origin_domain_elb          = aws_lb.mkt.dns_name
  lambda_arn                 = "arn:aws:lambda:us-east-1:211125478834:function:mkt-edge-router:14"
  origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"
  cert_arn                   = "arn:aws:acm:us-east-1:211125478834:certificate/ed6127af-7d88-4f93-a1a9-ad044a5155b6"
  s3_website_endpoint        = "revengegames-mkt.s3-website-sa-east-1.amazonaws.com"
}

resource "cloudflare_record" "api" {
  zone_id = data.cloudflare_zone.root.id
  name    = "mktbo.${local.root_domain}"
  value   = module.mkt_cloudfront.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = true
}