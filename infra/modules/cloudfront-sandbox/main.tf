provider "aws" {
  region = "us-east-1"
}
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 3.1.0"
    }
  }
}
resource "aws_acm_certificate" "cert" {
  domain_name       = "*.${var.root_domain}"
  validation_method = "DNS"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "sandbox - CloudFront Distribution pointing to ALB and S3"
  default_root_object = "index.html"
  aliases             = ["*.${var.root_domain}"]

  origin {
    domain_name = var.origin_domain_elb
    origin_id   = "ALB_${var.app_env}_Origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  origin {
    domain_name = var.origin_domain_elb
    origin_path = "/api/v1/client"
    origin_id   = "ALB_${var.app_env}_Origin - /api/v1/client (config.json, env-config.js)"

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
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id          = var.cache_policy_id
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    compress                 = true
    default_ttl              = 0
    max_ttl                  = 0
    min_ttl                  = 0
    origin_request_policy_id = var.origin_request_policy_id
    path_pattern             = "/config.json"
    smooth_streaming         = false
    target_origin_id         = "ALB_${var.app_env}_Origin - /api/v1/client (config.json, env-config.js)"
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
    target_origin_id         = "ALB_${var.app_env}_Origin"
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
    target_origin_id         = "ALB_${var.app_env}_Origin"
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
    target_origin_id         = "ALB_${var.app_env}_Origin"
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
    target_origin_id           = "ALB_${var.app_env}_Origin"
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
    target_origin_id           = "ALB_${var.app_env}_Origin"
    viewer_protocol_policy     = "allow-all"

  }

  ordered_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id            = "4cc15a8a-d715-48a4-82b8-cc0b614638fe"
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    compress                   = true
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    origin_request_policy_id   = var.origin_request_policy_id
    response_headers_policy_id = var.response_headers_policy_id
    path_pattern               = "/*/config"
    smooth_streaming           = false
    target_origin_id           = "ALB_${var.app_env}_Origin"
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
    target_origin_id           = "ALB_${var.app_env}_Origin"
    viewer_protocol_policy     = "allow-all"

    # lambda_function_association {
    #   event_type   = "origin-request"
    #   include_body = false
    #   lambda_arn   = var.lambda_arn
    # }

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

    min_ttl                  = 0
    default_ttl              = 0
    max_ttl                  = 0
    origin_request_policy_id = "33f36d7e-f396-46d9-90e0-52428a34d9dc"
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    compress                 = true
    viewer_protocol_policy   = "allow-all"

    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = var.lambda_arn
    }
  }



  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  depends_on = [aws_acm_certificate.cert, cloudflare_record.validation, aws_acm_certificate_validation.this]

  tags = {
    Environment = "${var.app_env}"
    Name        = "ALB ${var.app_env} CloudFront Distribution"
  }
}

##validation aws acm
resource "cloudflare_record" "validation" {
  # zone_id = data.cloudflare_zone.root.id
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.cloudflare_zone_id
  name    = each.value.name
  type    = each.value.type
  value   = each.value.record
  ttl     = 60

  depends_on = [aws_acm_certificate.cert]
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.cert.arn

  validation_record_fqdns = [
    for record in cloudflare_record.validation : record.hostname
  ]

  depends_on = [aws_acm_certificate.cert]
}