provider "aws" {
  region = "us-east-1"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Mkt - CloudFront Distribution pointing to ALB"
  default_root_object = "index.html"
  aliases             = ["mktbo.${var.root_domain}"]

  # continuous_deployment_policy_id = aws_cloudfront_continuous_deployment_policy.production.id

  origin {
    domain_name = var.origin_domain_elb
    origin_id   = "ALB_origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  origin {
    connection_attempts = 3
    connection_timeout  = 10
    domain_name         = var.s3_website_endpoint
    origin_id           = var.s3_website_endpoint

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "SSLv3",
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }

  ordered_cache_behavior {
    allowed_methods          = ["GET", "HEAD"]
    cache_policy_id          = var.cache_policy_id
    cached_methods           = ["GET", "HEAD"]
    compress                 = true
    default_ttl              = 0
    max_ttl                  = 0
    min_ttl                  = 0
    origin_request_policy_id = var.origin_request_policy_id
    path_pattern             = "/config.json"
    smooth_streaming         = false
    target_origin_id         = "ALB_origin"
    viewer_protocol_policy   = "allow-all"


    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = var.lambda_arn
    }
  }

  ordered_cache_behavior {
    allowed_methods          = ["GET", "HEAD"]
    cache_policy_id          = var.cache_policy_id
    cached_methods           = ["GET", "HEAD"]
    compress                 = true
    default_ttl              = 0
    max_ttl                  = 0
    min_ttl                  = 0
    origin_request_policy_id = var.origin_request_policy_id
    path_pattern             = "/env-config.*.js"
    smooth_streaming         = false
    target_origin_id         = "ALB_origin"
    viewer_protocol_policy   = "allow-all"

    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = var.lambda_arn
    }

  }

  ordered_cache_behavior {
    allowed_methods          = ["GET", "HEAD"]
    cache_policy_id          = var.cache_policy_id
    cached_methods           = ["GET", "HEAD"]
    compress                 = true
    default_ttl              = 0
    max_ttl                  = 0
    min_ttl                  = 0
    path_pattern             = "/client-env"
    origin_request_policy_id = var.origin_request_policy_id
    smooth_streaming         = false
    target_origin_id         = "ALB_origin"
    viewer_protocol_policy   = "allow-all"

  }

  ordered_cache_behavior {
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = var.cache_policy_id
    compress                 = true
    default_ttl              = 0
    max_ttl                  = 0
    min_ttl                  = 0
    path_pattern             = "/api/*"
    origin_request_policy_id = var.origin_request_policy_id
    smooth_streaming         = false
    target_origin_id         = "ALB_origin"
    viewer_protocol_policy   = "allow-all"

  }

  ordered_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cache_policy_id            = var.cache_policy_id
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    compress                   = true
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    origin_request_policy_id   = var.origin_request_policy_id
    response_headers_policy_id = var.response_headers_policy_id
    path_pattern               = "/client/*"
    smooth_streaming           = false
    target_origin_id           = "ALB_origin"
    viewer_protocol_policy     = "allow-all"

  }

  ordered_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cache_policy_id            = var.cache_policy_id
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    compress                   = true
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    origin_request_policy_id   = var.origin_request_policy_id
    response_headers_policy_id = var.response_headers_policy_id
    path_pattern               = "/*/spin"
    smooth_streaming           = false
    target_origin_id           = "ALB_origin"
    viewer_protocol_policy     = "allow-all"

  }

  ordered_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cache_policy_id            = var.cache_policy_id
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    origin_request_policy_id   = var.origin_request_policy_id
    response_headers_policy_id = var.response_headers_policy_id
    path_pattern               = "/*/config"
    smooth_streaming           = false
    target_origin_id           = "ALB_origin"
    viewer_protocol_policy     = "allow-all"

  }

  ordered_cache_behavior {
    allowed_methods          = ["GET", "HEAD"]
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    cached_methods           = ["GET", "HEAD"]
    compress                 = true
    default_ttl              = 0
    max_ttl                  = 0
    min_ttl                  = 0
    origin_request_policy_id = "33f36d7e-f396-46d9-90e0-52428a34d9dc"
    path_pattern             = "/src/*.jpg"
    smooth_streaming         = false
    target_origin_id         = var.s3_website_endpoint
    viewer_protocol_policy   = "allow-all"

    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = var.lambda_arn
    }

  }

  ordered_cache_behavior {
    allowed_methods          = ["GET", "HEAD"]
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    cached_methods           = ["GET", "HEAD"]
    compress                 = true
    default_ttl              = 0
    max_ttl                  = 0
    min_ttl                  = 0
    origin_request_policy_id = "33f36d7e-f396-46d9-90e0-52428a34d9dc"
    path_pattern             = "/index.html"
    smooth_streaming         = false
    target_origin_id         = var.s3_website_endpoint
    viewer_protocol_policy   = "allow-all"

    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = var.lambda_arn
    }

  }
  ordered_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    origin_request_policy_id   = "33f36d7e-f396-46d9-90e0-52428a34d9dc"
    response_headers_policy_id = var.response_headers_policy_id
    path_pattern               = "/env-config.js"
    smooth_streaming           = false
    target_origin_id           = "ALB_origin"
    viewer_protocol_policy     = "allow-all"

    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = var.lambda_arn
    }

  }

  ordered_cache_behavior {
    allowed_methods          = ["GET", "HEAD"]
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    cached_methods           = ["GET", "HEAD"]
    compress                 = true
    default_ttl              = 0
    max_ttl                  = 0
    min_ttl                  = 0
    origin_request_policy_id = "33f36d7e-f396-46d9-90e0-52428a34d9dc"
    path_pattern             = "/version.json"
    smooth_streaming         = false
    target_origin_id         = var.s3_website_endpoint
    viewer_protocol_policy   = "allow-all"

    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = var.lambda_arn
    }

  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_website_endpoint

    min_ttl                    = 0
    default_ttl                = 0
    max_ttl                    = 0
    origin_request_policy_id   = "33f36d7e-f396-46d9-90e0-52428a34d9dc"
    cache_policy_id            = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    response_headers_policy_id = var.response_headers_policy_id
    compress                   = true
    viewer_protocol_policy     = "allow-all"

    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = var.lambda_arn
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }


  tags = {
    Environment = "${var.app_env}"
    Name        = "ALB CloudFront Distribution"
  }
}




