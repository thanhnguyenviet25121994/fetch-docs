###################
## astar studio
##################

module "dev_astar_wildcard_cert" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.dev.${local.allstar_domain}"
  #   subject_alternative_names = [
  #     "*.${var.domain}"
  #   ]

  zone_id = data.cloudflare_zone.allstar.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.us-east-1
  }

}

resource "cloudflare_record" "dev_astar_validation" {
  count = length(module.dev_astar_wildcard_cert.distinct_domain_names)

  zone_id = data.cloudflare_zone.allstar.id
  name    = element(module.dev_astar_wildcard_cert.validation_domains, count.index)["resource_record_name"]
  type    = element(module.dev_astar_wildcard_cert.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.dev_astar_wildcard_cert.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}

resource "aws_s3_bucket" "astar_studio" {
  bucket = "studio.dev.${local.allstar_domain}"

  tags = {
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "astar_studio" {
  bucket = aws_s3_bucket.astar_studio.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "astar_studio" {
  bucket = aws_s3_bucket.astar_studio.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "astar_studio_s3_policy" {

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
      "${aws_s3_bucket.astar_studio.arn}/*",
    ]
  }

}

resource "aws_s3_bucket_policy" "astar_studio_bucket_policy" {
  bucket = aws_s3_bucket.astar_studio.id
  policy = data.aws_iam_policy_document.astar_studio_s3_policy.json
}



module "dev_astar_studio_cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  #   providers = {
  #     aws = aws.us-east-1
  #   }

  aliases = ["studio.dev.${local.allstar_domain}"]

  comment             = "${local.environment} Cloufront for astar studio"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  origin = {
    s3_dev_astar_studio = {
      domain_name = "${aws_s3_bucket_website_configuration.astar_studio.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    alb_dev = {
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
    target_origin_id             = "s3_dev_astar_studio"
    allowed_methods              = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods               = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy       = "redirect-to-https"
    use_forwarded_values         = false
    cache_policy_name            = "Managed-CachingOptimized"
    origin_request_policy_name   = "Managed-AllViewerExceptHostHeader"
    response_headers_policy_name = "Managed-SimpleCORS"
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
      path_pattern           = "/api/*"
      target_origin_id       = "alb_dev"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/index.html"
      target_origin_id       = "s3_dev_astar_studio"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["HEAD", "GET"]
      cached_methods  = ["GET", "HEAD"]
      default_ttl     = 0
      max_ttl         = 0
      min_ttl         = 0

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerExceptHostHeader"
      compress                   = true
    },
    {
      path_pattern           = "/auth/*"
      target_origin_id       = "alb_dev"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingOptimized"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/env-config.js"
      target_origin_id       = "alb_dev"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

      lambda_function_association = {

        origin-request = {
          lambda_arn = "arn:aws:lambda:us-east-1:211125478834:function:dev-studio-edge-router:3"
        }
      }
    },
    {
      path_pattern           = "/version.json"
      target_origin_id       = "s3_dev_astar_studio"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerExceptHostHeader"
      compress                   = true
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
    acm_certificate_arn      = module.dev_astar_wildcard_cert.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

}


resource "cloudflare_record" "dev_astar_studio" {
  zone_id = data.cloudflare_zone.allstar.id
  name    = "studio.dev"
  content = module.dev_astar_studio_cloudfront.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}







###################
## rectangle studio
##################

module "dev_rectangle_wildcard_cert" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.dev.${local.rectangle_domain}"
  #   subject_alternative_names = [
  #     "*.${var.domain}"
  #   ]

  zone_id = data.cloudflare_zone.rectangle.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.us-east-1
  }

}

resource "cloudflare_record" "dev_rectangle_validation" {
  count = length(module.dev_rectangle_wildcard_cert.distinct_domain_names)

  zone_id = data.cloudflare_zone.rectangle.id
  name    = element(module.dev_rectangle_wildcard_cert.validation_domains, count.index)["resource_record_name"]
  type    = element(module.dev_rectangle_wildcard_cert.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.dev_rectangle_wildcard_cert.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}

resource "aws_s3_bucket" "rectangle_studio" {
  bucket = "studio.dev.${local.rectangle_domain}"

  tags = {
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "rectangle_studio" {
  bucket = aws_s3_bucket.rectangle_studio.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "rectangle_studio" {
  bucket = aws_s3_bucket.rectangle_studio.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "rectangle_studio_s3_policy" {

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
      "${aws_s3_bucket.rectangle_studio.arn}/*",
    ]
  }

}

resource "aws_s3_bucket_policy" "rectangle_studio_bucket_policy" {
  bucket = aws_s3_bucket.rectangle_studio.id
  policy = data.aws_iam_policy_document.rectangle_studio_s3_policy.json
}



module "dev_rectangle_studio_cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  #   providers = {
  #     aws = aws.us-east-1
  #   }

  aliases = ["studio.dev.${local.rectangle_domain}"]

  comment             = "${local.environment} Cloufront for rectangle studio"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  origin = {
    s3_dev_rectangle_studio = {
      domain_name = "${aws_s3_bucket_website_configuration.rectangle_studio.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    alb_dev = {
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
    target_origin_id             = "s3_dev_rectangle_studio"
    allowed_methods              = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods               = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy       = "redirect-to-https"
    use_forwarded_values         = false
    cache_policy_name            = "Managed-CachingOptimized"
    origin_request_policy_name   = "Managed-AllViewerExceptHostHeader"
    response_headers_policy_name = "Managed-SimpleCORS"
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
      path_pattern           = "/api/*"
      target_origin_id       = "alb_dev"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/index.html"
      target_origin_id       = "s3_dev_rectangle_studio"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["HEAD", "GET"]
      cached_methods  = ["GET", "HEAD"]
      default_ttl     = 0
      max_ttl         = 0
      min_ttl         = 0

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerExceptHostHeader"
      compress                   = true
    },
    {
      path_pattern           = "/auth/*"
      target_origin_id       = "alb_dev"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingOptimized"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/env-config.js"
      target_origin_id       = "alb_dev"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

      lambda_function_association = {

        origin-request = {
          lambda_arn = "arn:aws:lambda:us-east-1:211125478834:function:dev-studio-edge-router:3"
        }
      }
    },
    {
      path_pattern           = "/version.json"
      target_origin_id       = "s3_dev_rectangle_studio"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerExceptHostHeader"
      compress                   = true
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
    acm_certificate_arn      = module.dev_rectangle_wildcard_cert.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

}

resource "cloudflare_record" "dev_rectangle_studio" {
  zone_id = data.cloudflare_zone.rectangle.id
  name    = "studio.dev"
  content = module.dev_rectangle_studio_cloudfront.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}



###############
### studio dev
###############

resource "aws_s3_bucket" "dev_studio" {
  bucket = "studio.dev.${local.root_domain}"

  tags = {
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "dev_studio" {
  bucket = aws_s3_bucket.dev_studio.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "dev_studio" {
  bucket = aws_s3_bucket.dev_studio.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "dev_studio_s3_policy" {

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
      "${aws_s3_bucket.dev_studio.arn}/*",
    ]
  }

}

resource "aws_s3_bucket_policy" "dev_studio_bucket_policy" {
  bucket = aws_s3_bucket.dev_studio.id
  policy = data.aws_iam_policy_document.dev_studio_s3_policy.json
}



module "dev_studio_cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  #   providers = {
  #     aws = aws.us-east-1
  #   }

  aliases = ["studio.dev.${local.root_domain}"]

  comment             = "${local.environment} Cloufront for dev studio"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  origin = {
    s3_dev_studio = {
      domain_name = "${aws_s3_bucket_website_configuration.dev_studio.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    alb_dev = {
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
    target_origin_id             = "s3_dev_studio"
    allowed_methods              = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods               = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy       = "redirect-to-https"
    use_forwarded_values         = false
    cache_policy_name            = "Managed-CachingDisabled"
    origin_request_policy_name   = "Managed-AllViewerExceptHostHeader"
    response_headers_policy_name = "Managed-SimpleCORS"
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
      path_pattern           = "/api/*"
      target_origin_id       = "alb_dev"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/auth/*"
      target_origin_id       = "alb_dev"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/env-config.js"
      target_origin_id       = "s3_dev_studio"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerExceptHostHeader"
      compress                   = true

    },
    {
      path_pattern           = "/version.json"
      target_origin_id       = "s3_dev_studio"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerExceptHostHeader"
      compress                   = true
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
    acm_certificate_arn      = "arn:aws:acm:us-east-1:211125478834:certificate/3f39864d-4f1e-4303-86ca-6720fd434880"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

}


resource "cloudflare_record" "dev_studio" {
  zone_id = data.cloudflare_zone.root.id
  name    = "studio.dev"
  content = module.dev_studio_cloudfront.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}