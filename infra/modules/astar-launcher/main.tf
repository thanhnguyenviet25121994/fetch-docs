resource "aws_s3_bucket" "this" {
  bucket = var.app_domain

  tags = {
    Name        = "${var.app_domain}"
    Environment = "${var.app_env}"
  }
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "this_s3_policy" {

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
      "${aws_s3_bucket.this.arn}/*",
    ]
  }

}

resource "aws_s3_bucket_policy" "this_bucket_policy" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this_s3_policy.json
}



module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  #   providers = {
  #     aws = aws.us-east-1
  #   }

  aliases = ["${var.app_domain}"]

  comment             = "${var.app_env} Cloufront for game ${var.app_domain}"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  origin = {
    "s3_${var.app_env}_${var.app_name}" = {
      domain_name = "${aws_s3_bucket_website_configuration.this.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    "alb_${var.app_env}_${var.app_name}" = {
      domain_name = "${var.alb_dns_name}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    "service-game-client-config.json" = {
      domain_name = "${var.alb_dns_name}"
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
    target_origin_id             = "s3_${var.app_env}_${var.app_name}"
    allowed_methods              = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods               = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy       = "redirect-to-https"
    use_forwarded_values         = false
    cache_policy_name            = "Managed-CachingDisabled"
    origin_request_policy_name   = "Managed-AllViewerAndCloudFrontHeaders-2022-06" # "AllViewerAndCloudFrontHeaders-2022-06"
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
      allowed_methods              = ["GET", "HEAD"]
      cache_policy_id              = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # disable cache
      cached_methods               = ["GET", "HEAD"]
      compress                     = true
      default_ttl                  = 0
      max_ttl                      = 0
      min_ttl                      = 0
      origin_request_policy_name   = "Managed-CORS-S3Origin" # CORS-S3Origin
      response_headers_policy_name = "Managed-CORS-With-Preflight"
      path_pattern                 = "/multiple.settings.json"
      smooth_streaming             = false
      target_origin_id             = "s3_${var.app_env}_${var.app_name}"
      viewer_protocol_policy       = "allow-all"
      use_forwarded_values         = false
    },
    {
      allowed_methods              = ["GET", "HEAD"]
      cache_policy_id              = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # disable cache
      cached_methods               = ["GET", "HEAD"]
      compress                     = true
      default_ttl                  = 0
      max_ttl                      = 0
      min_ttl                      = 0
      origin_request_policy_name   = "Managed-CORS-S3Origin" # CORS-S3Origin
      response_headers_policy_name = "Managed-CORS-With-Preflight"
      path_pattern                 = "/launcher.settings.json"
      smooth_streaming             = false
      target_origin_id             = "s3_${var.app_env}_${var.app_name}"
      viewer_protocol_policy       = "allow-all"
      use_forwarded_values         = false
    },
    {
      path_pattern           = "/env-config.js"
      target_origin_id       = "alb_${var.app_env}_${var.app_name}"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true


      lambda_function_association = {

        origin-request = {
          lambda_arn = "${var.lambda_edge_arn}"
        }
      }
    },
    {
      path_pattern           = "/env-config.*.js"
      target_origin_id       = "alb_${var.app_env}_${var.app_name}"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true


      lambda_function_association = {

        origin-request = {
          lambda_arn = "${var.lambda_edge_arn}"
        }
      }
    },
    {
      path_pattern           = "/client-env"
      target_origin_id       = "alb_${var.app_env}_${var.app_name}"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },
    {
      path_pattern           = "/index.html"
      target_origin_id       = "s3_${var.app_env}_${var.app_name}"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
      compress                   = true


      lambda_function_association = {

        origin-request = {
          lambda_arn = "${var.lambda_edge_arn}"
        }
      }
    },
    {
      path_pattern           = "/client/*"
      target_origin_id       = "alb_${var.app_env}_${var.app_name}"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },
    {
      path_pattern           = "/api/*"
      target_origin_id       = "alb_${var.app_env}_${var.app_name}"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },
    {
      path_pattern           = "/spin"
      target_origin_id       = "alb_${var.app_env}_${var.app_name}"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },
    {
      path_pattern           = "/config"
      target_origin_id       = "alb_${var.app_env}_${var.app_name}"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },
    {
      path_pattern           = "/version.json"
      target_origin_id       = "s3_${var.app_env}_${var.app_name}"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },
    {
      path_pattern           = "/config.json"
      target_origin_id       = "alb_${var.app_env}_${var.app_name}"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

      lambda_function_association = {

        origin-request = {
          lambda_arn = "${var.lambda_edge_arn}"
        }
      }

    }
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
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

}
