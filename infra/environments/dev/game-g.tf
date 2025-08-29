resource "aws_s3_bucket" "g" {
  bucket = "g.${local.environment}.revenge-games.com"

  tags = {
    Name        = "g.${local.environment}.revenge-games.com"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "g" {
  bucket = aws_s3_bucket.g.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "g" {
  bucket = aws_s3_bucket.g.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "g_s3_policy" {

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
      "${aws_s3_bucket.g.arn}/*",
    ]
  }

}

resource "aws_s3_bucket_policy" "g_bucket_policy" {
  bucket = aws_s3_bucket.g.id
  policy = data.aws_iam_policy_document.g_s3_policy.json
}



module "dev_g_cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  #   providers = {
  #     aws = aws.us-east-1
  #   }

  aliases = ["g.dev.revenge-games.com"]

  comment             = "Cloufront for game g"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  # create_origin_access_control = true
  # origin_access_control = {
  #   s3_dev_g = {
  #     description      = "CloudFront access to S3"
  #     origin_type      = "s3"
  #     signing_behavior = "always"
  #     signing_protocol = "sigv4"
  #   }
  # }

  origin = {
    s3_dev_g = {
      domain_name = "${aws_s3_bucket_website_configuration.g.website_endpoint}"
      # origin_access_control = "s3_dev_g"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    alb_dev = {
      domain_name = "${aws_lb.dev.dns_name}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    "ALB_dev_Origin - /api/v1/client (config.json, env-config.js)" = {
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
    target_origin_id             = "s3_dev_g"
    allowed_methods              = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods               = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy       = "redirect-to-https"
    use_forwarded_values         = false
    cache_policy_name            = "Managed-CachingDisabled"
    origin_request_policy_name   = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
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
      path_pattern           = "/health-check"
      target_origin_id       = "alb_dev"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      allowed_methods            = ["GET", "HEAD"]
      cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # disable cache
      cached_methods             = ["GET", "HEAD"]
      compress                   = true
      default_ttl                = 0
      max_ttl                    = 0
      min_ttl                    = 0
      origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # CORS-S3Origin
      response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"
      path_pattern               = "/*/multiple.settings.json"
      smooth_streaming           = false
      target_origin_id           = "s3_dev_g"
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
    },
    {
      allowed_methods            = ["GET", "HEAD"]
      cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # disable cache
      cached_methods             = ["GET", "HEAD"]
      compress                   = true
      default_ttl                = 0
      max_ttl                    = 0
      min_ttl                    = 0
      origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # CORS-S3Origin
      response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"
      path_pattern               = "/*/launcher.settings.json"
      smooth_streaming           = false
      target_origin_id           = "s3_dev_g"
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
    },
    {
      allowed_methods            = ["GET", "HEAD", "OPTIONS"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      compress                   = true
      default_ttl                = 0
      max_ttl                    = 0
      min_ttl                    = 0
      path_pattern               = "/*/config.json"
      smooth_streaming           = false
      target_origin_id           = "ALB_dev_Origin - /api/v1/client (config.json, env-config.js)"
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "UseOriginCacheControlHeaders-QueryStrings"
      origin_request_policy_name = "Managed-AllViewer"
      # response_headers_policy_name = "Managed-CORS-With-Preflight"

    },
    {
      allowed_methods            = ["GET", "HEAD", "OPTIONS", "DELETE", "PATCH", "POST", "PUT"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      compress                   = true
      default_ttl                = 0
      max_ttl                    = 0
      min_ttl                    = 0
      path_pattern               = "/client/*"
      smooth_streaming           = false
      target_origin_id           = "alb_dev"
      viewer_protocol_policy     = "https-only"
      use_forwarded_values       = false
      cache_policy_name          = "UseOriginCacheControlHeaders"
      origin_request_policy_name = "Managed-AllViewer"
      # response_headers_policy_name = "Managed-CORS-With-Preflight"

    },
    {
      allowed_methods            = ["GET", "HEAD", "OPTIONS"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      compress                   = true
      default_ttl                = 0
      max_ttl                    = 0
      min_ttl                    = 0
      path_pattern               = "/*/config"
      smooth_streaming           = false
      target_origin_id           = "alb_dev"
      viewer_protocol_policy     = "https-only"
      use_forwarded_values       = false
      cache_policy_name          = "UseOriginCacheControlHeaders-QueryStrings"
      origin_request_policy_name = "Managed-AllViewer"
      # response_headers_policy_name = "Managed-CORS-With-Preflight"

    },
    {
      allowed_methods            = ["GET", "HEAD", "OPTIONS", "DELETE", "PATCH", "POST", "PUT"]
      cached_methods             = ["GET", "HEAD", "OPTIONS"]
      compress                   = true
      default_ttl                = 0
      max_ttl                    = 0
      min_ttl                    = 0
      path_pattern               = "/*/spin"
      smooth_streaming           = false
      target_origin_id           = "alb_dev"
      viewer_protocol_policy     = "https-only"
      use_forwarded_values       = false
      cache_policy_name          = "UseOriginCacheControlHeaders"
      origin_request_policy_name = "Managed-AllViewer"
      # response_headers_policy_name = "Managed-CORS-With-Preflight"

    }
  ]

  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:211125478834:certificate/3f39864d-4f1e-4303-86ca-6720fd434880"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

}


# resource "cloudflare_record" "dev_g" {
#   zone_id = data.cloudflare_zone.root.id
#   name    = "g.dev"
#   content = module.dev_g_cloudfront.cloudfront_distribution_domain_name
#   type    = "CNAME"
#   proxied = false
# }