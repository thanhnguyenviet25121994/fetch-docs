resource "aws_s3_bucket" "pp" {
  bucket = "pp.lnga-rg.com"

  tags = {
    Name        = "revengegames-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "pp" {
  bucket = aws_s3_bucket.pp.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "pp_public" {
  bucket = aws_s3_bucket.pp.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "pp_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.pp.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.pp_public
  ]
}

resource "aws_s3_bucket_policy" "pp_allow_public_access" {
  bucket = aws_s3_bucket.pp.id
  policy = data.aws_iam_policy_document.pp_s3_allow_public_access.json
}

module "pp_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name = aws_s3_bucket.pp.bucket
  zone_id     = data.cloudflare_zone.root.id

  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.global
  }
}

resource "cloudflare_record" "pp_acm" {
  for_each = {
    for dvo in module.pp_acm.validation_domains : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      content = dvo.resource_record_value
    }
  }

  zone_id = data.cloudflare_zone.root.id
  type    = each.value.type
  name    = trimsuffix(each.value.name, ".")
  content = trimsuffix(each.value.content, ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}

resource "cloudflare_record" "pp" {
  zone_id = data.cloudflare_zone.root.id
  name    = "pp"
  type    = "CNAME"
  content = module.cloudfront_lobby.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

module "cloudfront_pp" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = [aws_s3_bucket.pp.bucket]
  comment = "CloudFront for Revenge games (EU, Sandbox)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = module.pp_acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  origin = {
    s3 = {
      domain_name = "${aws_s3_bucket_website_configuration.pp.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
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
    target_origin_id           = "s3"
    allowed_methods            = ["HEAD", "GET"]
    cached_methods             = ["HEAD", "GET"]
    viewer_protocol_policy     = "allow-all"
    use_forwarded_values       = false
    cache_policy_name          = "Managed-CachingOptimized"
    origin_request_policy_name = "Managed-AllViewer"
    compress                   = true
  }

  ordered_cache_behavior = [
    {
      path_pattern               = "/gs2c/v3/gameService"
      target_origin_id           = "elb"
      allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/gs2c/stats.do"
      target_origin_id           = "elb"
      allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingOptimized"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/gs2c/saveSettings.do"
      target_origin_id           = "elb"
      allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "UseOriginCacheControlHeaders"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/gs2c/reloadBalance.do"
      target_origin_id           = "elb"
      allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "UseOriginCacheControlHeaders"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/gs2c/announcements/*"
      target_origin_id           = "elb"
      allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingOptimized"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/health-check"
      target_origin_id       = "elb"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/gs2c/promo/active/"
      target_origin_id           = "elb"
      allowed_methods            = ["GET", "HEAD"]
      cached_methods             = ["GET", "HEAD"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingOptimized"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/gs2c/promo/frb/available"
      target_origin_id           = "elb"
      allowed_methods            = ["GET", "HEAD"]
      cached_methods             = ["GET", "HEAD"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingOptimized"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/history/api/*"
      target_origin_id           = "elb"
      allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "UseOriginCacheControlHeaders-QueryStrings"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/history/*"
      target_origin_id           = "s3"
      allowed_methods            = ["GET", "HEAD"]
      cached_methods             = ["GET", "HEAD"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingOptimized"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/*/"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "GET"]
      cached_methods             = ["HEAD", "GET"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "UseOriginCacheControlHeaders-QueryStrings"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/gs2c/common/v4/games-html5/games/vs/*/*/customizations.info"
      target_origin_id       = "elb"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["HEAD", "GET", "OPTIONS"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]
      default_ttl     = 0
      max_ttl         = 0
      min_ttl         = 0

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    }
  ]
}
