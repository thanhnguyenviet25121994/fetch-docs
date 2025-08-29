resource "aws_s3_bucket" "rc" {
  bucket = "rc.${local.dev_root_domain}"

  tags = {
    Name        = "${local.dev_root_domain}"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "rc" {
  bucket = aws_s3_bucket.rc.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "rc_public" {
  bucket = aws_s3_bucket.rc.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "rc_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.rc.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.rc_public
  ]
}

resource "aws_s3_bucket_policy" "rc_allow_public_access" {
  bucket = aws_s3_bucket.rc.id
  policy = data.aws_iam_policy_document.rc_s3_allow_public_access.json
}

resource "cloudflare_record" "rc" {
  zone_id = data.cloudflare_zone.root.id
  name    = "rc.dev"
  type    = "CNAME"
  content = module.cloudfront_rc.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

module "cloudfront_rc" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = [aws_s3_bucket.rc.bucket]
  comment = "CloudFront for Revenge games dev)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:211125478834:certificate/3f39864d-4f1e-4303-86ca-6720fd434880"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  origin = {
    s3 = {
      domain_name = "${aws_s3_bucket_website_configuration.rc.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    elb = {
      domain_name = "${aws_lb.dev.dns_name}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    "elb https" = {
      domain_name = "${aws_lb.dev.dns_name}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
    elb_config = {
      domain_name = "${aws_lb.dev.dns_name}"
      origin_path = "/api/v1/client"
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
    cache_policy_name          = "Managed-CachingDisabled"
    origin_request_policy_name = "Managed-AllViewer"
    compress                   = true
  }

  ordered_cache_behavior = [
    {
      path_pattern               = "/api/*"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods             = ["HEAD", "GET", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "UseOriginCacheControlHeaders-QueryStrings"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/client/*"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods             = ["HEAD", "GET", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "UseOriginCacheControlHeaders-QueryStrings"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/*/spin"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods             = ["HEAD", "GET", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "UseOriginCacheControlHeaders-QueryStrings"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/*/config"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "GET", "OPTIONS"]
      cached_methods             = ["HEAD", "GET", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "UseOriginCacheControlHeaders-QueryStrings"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/*/config.json"
      target_origin_id           = "elb_config"
      allowed_methods            = ["HEAD", "GET", "OPTIONS"]
      cached_methods             = ["HEAD", "GET", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "UseOriginCacheControlHeaders-QueryStrings"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/*/env-config.js"
      target_origin_id           = "elb_config"
      allowed_methods            = ["HEAD", "GET", "OPTIONS"]
      cached_methods             = ["HEAD", "GET", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "UseOriginCacheControlHeaders-QueryStrings"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/*/version.json"
      target_origin_id           = "s3"
      allowed_methods            = ["HEAD", "GET", "OPTIONS"]
      cached_methods             = ["HEAD", "GET", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    # {
    #   path_pattern           = "/ws"
    #   target_origin_id       = "elb"
    #   allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    #   cached_methods         = ["HEAD", "GET", "OPTIONS"]
    #   viewer_protocol_policy = "allow-all"
    #   use_forwarded_values   = false
    #   cache_policy_name          = "Managed-CachingDisabled"
    #   origin_request_policy_name = "Managed-AllViewer"
    #   compress = true
    # },
  ]
}

