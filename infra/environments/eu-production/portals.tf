module "prd_eu_portal_replay" {
  source = "../../modules/portal-replay"
  providers = {
    aws = aws.current
  }

  app_env   = local.environment
  domain    = "replay.${local.root_domain}"
  image     = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/portal-replay:${local.portal_replay_version}"
  value_dns = module.prd_eu_cloudfront_portal_replay.cloudfront_distribution_domain_name
  app_dns   = "replay.${local.root_domain}"
  role      = aws_iam_role.prd_eu_service

  network_configuration = {
    region = "${local.region}"
    vpc    = module.prd_eu_networking.vpc
    subnets = [
      module.prd_eu_networking.subnet_private_1.id,
      module.prd_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prd_eu_networking.vpc.default_security_group_id
    ]
    load_balancer = aws_lb.prd_eu
  }

  depends_on = [
    aws_iam_role.prd_eu_service,
    aws_iam_role_policy.prd_eu_service_policy,
  ]
}


module "prd_eu_cloudfront_portal_replay" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = ["replay.${local.root_domain}"]
  comment = "CloudFront for replay (EU, prod)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = module.prd_acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  origin = {
    elb = {
      domain_name = "${aws_lb.prd_eu.dns_name}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id           = "elb"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    viewer_protocol_policy     = "allow-all"
    use_forwarded_values       = false
    cache_policy_name          = "Managed-CachingOptimized"
    origin_request_policy_name = "Managed-AllViewer"
    compress                   = true
  }

  custom_error_response = [
    {
      error_caching_min_ttl = 10
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
    }
  ]

}