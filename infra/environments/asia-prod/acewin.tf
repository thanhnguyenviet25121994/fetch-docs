resource "aws_s3_bucket" "acewin" {
  bucket = "static.${local.aw_domain}"

  tags = {
    Name        = "${local.aw_domain}"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "acewin" {
  bucket = aws_s3_bucket.acewin.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "acewin_public" {
  bucket = aws_s3_bucket.acewin.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "acewin_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.acewin.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.acewin_public
  ]
}

resource "aws_s3_bucket_policy" "acewin_allow_public_access" {
  bucket = aws_s3_bucket.acewin.id
  policy = data.aws_iam_policy_document.acewin_s3_allow_public_access.json
}


resource "cloudflare_record" "staticacewin" {
  zone_id = data.cloudflare_zone.aw.id
  name    = "static"
  type    = "CNAME"
  content = module.cloudfront_acewin.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

module "cloudfront_acewin" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = [aws_s3_bucket.acewin.bucket]
  comment = "CloudFront for acewin Gaming clone (prod)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = module.aw_acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  origin = {
    s3 = {
      domain_name = "${aws_s3_bucket_website_configuration.acewin.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    elb = {
      domain_name = "${aws_lb.prod_asia.dns_name}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id           = "s3"
    allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods             = ["HEAD", "GET", "OPTIONS"]
    viewer_protocol_policy     = "allow-all"
    use_forwarded_values       = false
    cache_policy_name          = "Managed-CachingDisabled"
    origin_request_policy_name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
    compress                   = true
  }

  ordered_cache_behavior = [

  ]
}




##############
### service-acewin-adaptor
#############
module "prod_asia_service_acewin_adaptor" {
  providers = {
    aws = aws.current
  }

  source = "../../modules/service-acewin-adaptor"



  app_env = local.environment
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-acewin-adaptor:v1.0.28.1"


  env = {
    LOG_LEVEL                      = "error"
    NODE_ENV                       = "development"
    SGC_HOST                       = "http://service-game-client"
    GAME_CODE_PREFIX               = "acewin-"
    API_HOST                       = "https://api.${local.aw_domain}"
    STATIC_HOST                    = "https://static.${local.aw_domain}"
    PORT                           = "8080"
    SERVICE_CLIENT_REQUEST_TIMEOUT = "10000"
  }

  role = aws_iam_role.prod_asia_service
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prod_asia_networking.vpc
    subnets = [
      module.prod_asia_networking.subnet_private_1.id,
      module.prod_asia_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prod_asia_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_asia_service_acewin_adaptor.arn,
      port = 8080
    }]
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
  ]
}

resource "aws_lb_target_group" "prod_asia_service_acewin_adaptor" {
  name        = "${local.environment}-service-acewin-adaptor"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_asia_networking.vpc.id
  target_type = "ip"

  health_check {
    path                = "/health-check"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  tags = {
    Environment = local.environment
  }
}

resource "aws_lb_listener_rule" "prod_asia_service_acewin_adaptor" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 2220

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_asia_service_acewin_adaptor.arn
  }

  condition {
    host_header {
      values = ["api.${local.aw_domain}"]
    }
  }

  tags = {
    Name        = "api.${local.aw_domain}"
    Environment = "prod_asia"
  }
}


resource "cloudflare_record" "prod_asia_service_acewin_adaptor" {
  zone_id = data.cloudflare_zone.aw.id
  name    = "api"
  content = module.global_accelerator.dns_name
  type    = "CNAME"
  proxied = true
}