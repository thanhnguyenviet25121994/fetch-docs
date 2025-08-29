resource "aws_s3_bucket" "pg" {
  bucket = "payment.dev.revenge-games.com"

  tags = {
    Name        = "payment.dev.revenge-games.com"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "pg" {
  bucket = aws_s3_bucket.pg.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "pg" {
  bucket = aws_s3_bucket.pg.bucket

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
      "${aws_s3_bucket.pg.arn}/*",
    ]
  }

}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.pg.id
  policy = data.aws_iam_policy_document.s3_policy.json
}



module "dev_pg_cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  #   providers = {
  #     aws = aws.us-east-1
  #   }

  aliases = ["payment.dev.revenge-games.com", "demo-merchant.dev.revenge-games.com"]

  comment             = "Cloufront for pg portal"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  # create_origin_access_control = true
  # origin_access_control = {
  #   s3_dev_pg = {
  #     description      = "CloudFront access to S3"
  #     origin_type      = "s3"
  #     signing_behavior = "always"
  #     signing_protocol = "sigv4"
  #   }
  # }

  origin = {
    s3_dev_pg = {
      domain_name = "${aws_s3_bucket_website_configuration.pg.website_endpoint}"
      # origin_access_control = "s3_dev_pg"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    alb_dev_pg = {
      domain_name = "${module.alb.dns_name}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }
  default_cache_behavior = {
    target_origin_id             = "s3_dev_pg"
    allowed_methods              = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods               = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy       = "redirect-to-https"
    use_forwarded_values         = false
    cache_policy_name            = "Managed-CachingDisabled"
    origin_request_policy_name   = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
    response_headers_policy_name = "Managed-SimpleCORS"
    compress                     = true

    # response_headers_policy_name = "Managed-CORS-With-Preflight"
    # lambda_function_association = {

    #   origin-request = {
    #     lambda_arn = "arn:aws:lambda:us-east-1:211125478834:function:dev-pg-edge-router:2"
    #   }
    # }
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/bo/*"
      target_origin_id       = "s3_dev_pg"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerExceptHostHeader"
      compress                   = true
    },
    {
      path_pattern           = "/api/*"
      target_origin_id       = "alb_dev_pg"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/actuator/health"
      target_origin_id       = "alb_dev_pg"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/api-docs"
      target_origin_id       = "alb_dev_pg"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/api-docs/*"
      target_origin_id       = "alb_dev_pg"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/swagger-ui"
      target_origin_id       = "alb_dev_pg"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/webjars/swagger-ui/*"
      target_origin_id       = "alb_dev_pg"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    }
    # {
    #   path_pattern           = "/index.html"
    #   target_origin_id       = "s3_dev_pg"
    #   viewer_protocol_policy = "redirect-to-https"

    #   allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    #   cached_methods  = ["GET", "HEAD", "OPTIONS"]

    #   use_forwarded_values = false

    #   cache_policy_name          = "Managed-CachingDisabled"
    #   origin_request_policy_name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
    #   compress                   = true


    #   # lambda_function_association = {

    #   #   origin-request = {
    #   #     lambda_arn = "arn:aws:lambda:us-east-1:211125478834:function:dev-pg-edge-router:2"
    #   #   }
    #   # }
    # }
  ]

  custom_error_response = [
    {
      error_caching_min_ttl = 10
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
    }
  ]


  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:211125478834:certificate/3f39864d-4f1e-4303-86ca-6720fd434880"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

}


resource "cloudflare_record" "dev_pg" {
  zone_id = data.cloudflare_zone.root.id
  name    = "payment.dev"
  content = module.dev_pg_cloudfront.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}

resource "cloudflare_record" "dev_pg_merchant" {
  zone_id = data.cloudflare_zone.root.id
  name    = "demo-merchant.dev"
  content = module.dev_pg_cloudfront.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}