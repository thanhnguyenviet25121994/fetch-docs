module "sandbox_cloudfront" {
  source = "../../modules/cloudfront-sandbox"

  app_env                    = local.environment
  root_domain                = "sandbox.${local.root_domain}"
  origin_domain_elb          = aws_lb.staging.dns_name
  lambda_arn                 = "arn:aws:lambda:us-east-1:211125478834:function:sandbox-edge-router:15"
  origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"
  s3_website_endpoint        = aws_s3_bucket_website_configuration.this.website_endpoint

  cloudflare_zone_id = data.cloudflare_zone.root.id


}