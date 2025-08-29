resource "aws_s3_bucket" "pgs" {
  bucket = "static.pgs.sandbox.${local.root_domain}"

  tags = {
    Name        = "revengegames-pgs-sandbox"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "pgs" {
  bucket = aws_s3_bucket.pgs.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "pgs_public" {
  bucket = aws_s3_bucket.pgs.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "pgs_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.pgs.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.pgs_public
  ]
}

resource "aws_s3_bucket_policy" "pgs_allow_public_access" {
  bucket = aws_s3_bucket.pgs.id
  policy = data.aws_iam_policy_document.pgs_s3_allow_public_access.json
}



resource "cloudflare_record" "apipgs" {
  zone_id = data.cloudflare_zone.root.id
  name    = "api.pgs.sandbox"
  type    = "CNAME"
  content = module.cloudfront_api_pgs.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

resource "cloudflare_record" "staticpgs" {
  zone_id = data.cloudflare_zone.root.id
  name    = "static.pgs.sandbox"
  type    = "CNAME"
  content = module.cloudfront_pgs.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

module "cloudfront_pgs" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = [aws_s3_bucket.pgs.bucket, "m.pgs.sandbox.${local.root_domain}"]
  comment = "CloudFront for PG soft clone (sandbox)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = module.pgs_acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  origin = {
    s3 = {
      domain_name = "${aws_s3_bucket_website_configuration.pgs_new.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    # elb = {
    #   domain_name = "${aws_lb.staging.dns_name}"
    #   custom_origin_config = {
    #     http_port              = 80
    #     https_port             = 443
    #     origin_protocol_policy = "http-only"
    #     origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    #   }
    # }
  }

  default_cache_behavior = {
    target_origin_id           = "s3"
    allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods             = ["HEAD", "GET", "OPTIONS"]
    viewer_protocol_policy     = "allow-all"
    use_forwarded_values       = false
    cache_policy_name          = "Managed-CachingDisabled"
    origin_request_policy_name = "Managed-AllViewerExceptHostHeader"
    compress                   = true
  }

  ordered_cache_behavior = [
    {
      path_pattern                 = "/shared/service-worker/sw.js"
      target_origin_id             = "s3"
      allowed_methods              = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods               = ["HEAD", "GET", "OPTIONS"]
      viewer_protocol_policy       = "allow-all"
      use_forwarded_values         = false
      cache_policy_name            = "Managed-CachingDisabled"
      origin_request_policy_name   = "Managed-CORS-S3Origin"
      response_headers_policy_name = "sw-pgs"
      compress                     = true
    },
  ]

  logging_config = {
    bucket = "revengegames-pgs-log.s3.amazonaws.com"
    prefix = "sandbox/cloudfront/static"
  }
}



### cloudfront api
module "cloudfront_api_pgs" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = ["api.pgs.sandbox.${local.root_domain}"]
  comment = "CloudFront for PG soft clone (sandbox)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = module.pgs_acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  origin = {
    elb = {
      domain_name = "${aws_lb.staging.dns_name}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id           = "elb"
    allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods             = ["HEAD", "GET", "OPTIONS"]
    viewer_protocol_policy     = "allow-all"
    use_forwarded_values       = false
    cache_policy_name          = "Managed-CachingDisabled"
    origin_request_policy_name = "Managed-AllViewer"
    compress                   = true
  }

  ordered_cache_behavior = [

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

  ]
}






#################################
###### m.pgs
################################
resource "aws_s3_bucket" "mpgs" {
  bucket = "m.pgs.sandbox.${local.root_domain}"

  tags = {
    Name        = "m-pgs-sandbox"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "mpgs" {
  bucket = aws_s3_bucket.mpgs.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "mpgs_public" {
  bucket = aws_s3_bucket.mpgs.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "mpgs_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.mpgs.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.mpgs_public
  ]
}

resource "aws_s3_bucket_policy" "mpgs_allow_public_access" {
  bucket = aws_s3_bucket.mpgs.id
  policy = data.aws_iam_policy_document.mpgs_s3_allow_public_access.json
}


resource "cloudflare_record" "mpgs" {
  zone_id = data.cloudflare_zone.root.id
  name    = "m.pgs.sandbox"
  type    = "CNAME"
  content = module.cloudfront_pgs.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}


# module "cloudfront_mpgs" {
#   source  = "terraform-aws-modules/cloudfront/aws"
#   version = "v3.4.0"

#   aliases = [aws_s3_bucket.mpgs.bucket]
#   comment = "CloudFront for PG soft clone (sandbox)"

#   enabled             = true
#   is_ipv6_enabled     = true
#   retain_on_delete    = false
#   wait_for_deployment = false

#   default_root_object = "index.html"

#   viewer_certificate = {
#     acm_certificate_arn      = module.pgs_acm.acm_certificate_arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2021"
#   }

#   origin = {
#     s3 = {
#       domain_name = "${aws_s3_bucket_website_configuration.mpgs.website_endpoint}"
#       custom_origin_config = {
#         http_port              = 80
#         https_port             = 443
#         origin_protocol_policy = "http-only"
#         origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
#       }
#     }
#     elb = {
#       domain_name = "${aws_lb.staging.dns_name}"
#       custom_origin_config = {
#         http_port              = 80
#         https_port             = 443
#         origin_protocol_policy = "http-only"
#         origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
#       }
#     }
#   }

#   default_cache_behavior = {
#     target_origin_id           = "s3"
#     allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
#     cached_methods             = ["HEAD", "GET", "OPTIONS"]
#     viewer_protocol_policy     = "allow-all"
#     use_forwarded_values       = false
#     cache_policy_name          = "Managed-CachingDisabled"
#     origin_request_policy_name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
#     compress                   = true
#   }

#   ordered_cache_behavior = [

#     {
#       path_pattern           = "/health-check"
#       target_origin_id       = "elb"
#       viewer_protocol_policy = "allow-all"

#       allowed_methods = ["GET", "HEAD", "OPTIONS"]
#       cached_methods  = ["GET", "HEAD", "OPTIONS"]

#       use_forwarded_values = false

#       cache_policy_name          = "Managed-CachingDisabled"
#       origin_request_policy_name = "Managed-AllViewer"
#       compress                   = true
#     },
#     {
#       path_pattern                 = "/shared/service-worker/sw.js"
#       target_origin_id             = "s3"
#       allowed_methods              = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
#       cached_methods               = ["HEAD", "GET", "OPTIONS"]
#       viewer_protocol_policy       = "allow-all"
#       use_forwarded_values         = false
#       cache_policy_name            = "Managed-CachingDisabled"
#       origin_request_policy_name   = "Managed-CORS-S3Origin"
#       response_headers_policy_name = "sw-pgs"
#       compress                     = true
#     },
#   ]
# }


resource "aws_s3_bucket" "pgs_new" {
  bucket = "revengegames-pgs-sandbox"

  tags = {
    Name        = "revengegames-pgs-sandbox"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "pgs_new" {
  bucket = aws_s3_bucket.pgs_new.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "pgs_new_public" {
  bucket = aws_s3_bucket.pgs_new.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "pgs_new_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.pgs_new.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.pgs_new_public
  ]
}

resource "aws_s3_bucket_policy" "pgs_new_allow_public_access" {
  bucket = aws_s3_bucket.pgs_new.id
  policy = data.aws_iam_policy_document.pgs_new_s3_allow_public_access.json
}