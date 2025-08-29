resource "aws_s3_bucket" "pp" {
  bucket = var.domain

  tags = {
    Name        = "${var.domain}"
    Environment = var.app_env
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

resource "aws_s3_bucket_public_access_block" "pp" {
  bucket = aws_s3_bucket.pp.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "s3_policy" {

  # Origin Access Controls
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

}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.pp.id
  policy = data.aws_iam_policy_document.s3_policy.json
}



module "pp_cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  #   providers = {
  #     aws = aws.us-east-1
  #   }

  aliases = ["${var.domain}"]

  comment             = "${var.app_env} Cloufront for game clone pp"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  # create_origin_access_control = true
  # origin_access_control = {
  #   s3_${var.app_env}_pp = {
  #     description      = "CloudFront access to S3"
  #     origin_type      = "s3"
  #     signing_behavior = "always"
  #     signing_protocol = "sigv4"
  #   }
  # }

  origin = {
    "s3_${var.app_env}_pp" = {
      domain_name = "${aws_s3_bucket_website_configuration.pp.website_endpoint}"
      # origin_access_control = "s3_${var.app_env}_pp"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    "alb_${var.app_env}" = {
      domain_name = "${var.alb_dns_name}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }
  default_cache_behavior = {
    target_origin_id             = "s3_${var.app_env}_pp"
    allowed_methods              = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods               = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy       = "redirect-to-https"
    use_forwarded_values         = false
    cache_policy_name            = "Managed-CachingDisabled"
    origin_request_policy_name   = "Managed-AllViewerExceptHostHeader"
    response_headers_policy_name = "Managed-CORS-With-Preflight"
    compress                     = true

    # response_headers_policy_name = "Managed-CORS-With-Preflight"
    # lambda_function_association = {

    #   origin-request = {
    #     lambda_arn = "arn:aws:lambda:us-east-1:211125478834:function:test-router:5"
    #   }
    # }
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/gs2c/v3/gameService"
      target_origin_id       = "alb_${var.app_env}"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/gs2c/stats.do"
      target_origin_id       = "alb_${var.app_env}"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name            = "Managed-CachingDisabled"
      origin_request_policy_name   = "Managed-AllViewer"
      response_headers_policy_name = "Managed-SimpleCORS"
      compress                     = true
    },
    {
      path_pattern           = "/gs2c/saveSettings.do"
      target_origin_id       = "alb_${var.app_env}"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "UseOriginCacheControlHeaders"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/gs2c/reloadBalance.do"
      target_origin_id       = "alb_${var.app_env}"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "UseOriginCacheControlHeaders"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/gs2c/announcements/*"
      target_origin_id       = "alb_${var.app_env}"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/health-check"
      target_origin_id       = "alb_${var.app_env}"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/history/api/*"
      target_origin_id       = "alb_${var.app_env}"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]
      default_ttl     = 0
      max_ttl         = 0
      min_ttl         = 0

      use_forwarded_values = false

      cache_policy_name          = "UseOriginCacheControlHeaders"
      origin_request_policy_id   = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"
      smooth_streaming           = false
      compress                   = true
    },
    {
      path_pattern           = "/history/*"
      target_origin_id       = "s3_${var.app_env}_pp"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]
      default_ttl     = 0
      max_ttl         = 0
      min_ttl         = 0

      use_forwarded_values = false

      cache_policy_name = "Managed-CachingDisabled"
      smooth_streaming  = false
      compress          = true
    },
    {
      path_pattern           = "/*/"
      target_origin_id       = "alb_${var.app_env}"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["HEAD", "GET"]
      cached_methods  = ["GET", "HEAD"]
      default_ttl     = 0
      max_ttl         = 0
      min_ttl         = 0

      use_forwarded_values = false

      cache_policy_name        = "Managed-CachingDisabled"
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      # response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"
      compress = true
    },
    {
      path_pattern           = "/gs2c/promo/active/"
      target_origin_id       = "alb_${var.app_env}"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["HEAD", "GET", "OPTIONS"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]
      default_ttl     = 0
      max_ttl         = 0
      min_ttl         = 0

      use_forwarded_values = false

      cache_policy_name          = "UseOriginCacheControlHeaders"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/gs2c/promo/frb/available"
      target_origin_id       = "alb_${var.app_env}"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["HEAD", "GET", "OPTIONS"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]
      default_ttl     = 0
      max_ttl         = 0
      min_ttl         = 0

      use_forwarded_values = false

      cache_policy_name          = "UseOriginCacheControlHeaders"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/gs2c/common/v4/games-html5/games/vs/*/*/customizations.info"
      target_origin_id       = "alb_${var.app_env}"
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
    },
    {
      path_pattern           = "/gs2c/common/v1/games-html5/games/vs/*/*/customizations.info"
      target_origin_id       = "alb_${var.app_env}"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["HEAD", "GET", "OPTIONS"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]
      default_ttl     = 0
      max_ttl         = 0
      min_ttl         = 0

      use_forwarded_values = false

      cache_policy_name        = "Managed-CachingDisabled"
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
      # response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"
      compress = true
    }
  ]


  viewer_certificate = {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  logging_config = var.logging_config

}


# resource "cloudflare_record" "${var.app_env}_pp" {
#   zone_id = data.cloudflare_zone.root.id
#   name    = "pp.${var.app_env}"
#   content = module.${var.app_env}_pp_cloudfront.cloudfront_distribution_domain_name
#   type    = "CNAME"
#   proxied = false
# }