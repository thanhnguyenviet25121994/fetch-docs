locals {
  pgs_domain = "1adz83lbv.com"
}

data "cloudflare_zone" "pgs" {
  name = local.pgs_domain
}

resource "aws_s3_bucket" "pgs" {
  bucket = "static.${local.pgs_domain}"

  tags = {
    Name        = "revengegames-pgs-prod"
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
# resource "aws_s3_bucket_cors_configuration" "static_cors" {
#   bucket = aws_s3_bucket.pgs.id  # Your static content bucket

#   cors_rule {
#     allowed_headers = ["*"]
#     allowed_methods = ["GET", "HEAD"]  # S3 only supports these methods for CORS
#     allowed_origins = [
#       "https://m.1adz83lbv.com",      # Your mobile domain
#       "https://static.1adz83lbv.com"   # Your static domain
#     ]
#     max_age_seconds = 3000
#   }
# }
# resource "aws_s3_bucket_cors_configuration" "mpgs_cors" {
#   bucket = aws_s3_bucket.mpgs.id

#   cors_rule {
#     allowed_headers = ["*"]
#     allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
#     allowed_origins = ["*"]  # Allow all origins (adjust in production)
#     expose_headers  = ["ETag"]
#     max_age_seconds = 3000
#   }
# }


resource "cloudflare_record" "apipgs" {
  zone_id = data.cloudflare_zone.pgs.id
  name    = "api"
  type    = "CNAME"
  content = "af88f7c2d37bfb364.awsglobalaccelerator.com"
  proxied = true

  allow_overwrite = true
}

resource "cloudflare_record" "staticpgs" {
  zone_id = data.cloudflare_zone.pgs.id
  name    = "static"
  type    = "CNAME"
  content = module.cloudfront_pgs.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

module "cloudfront_pgs" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = [aws_s3_bucket.pgs.bucket, "m.1adz83lbv.com"]
  comment = "CloudFront for PG soft clone (prod)"

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
      domain_name = "${aws_s3_bucket_website_configuration.pgs2.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id             = "s3"
    allowed_methods              = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods               = ["HEAD", "GET", "OPTIONS"]
    viewer_protocol_policy       = "allow-all"
    use_forwarded_values         = false
    cache_policy_name            = "Managed-CachingDisabled"
    origin_request_policy_name   = "Managed-AllViewerExceptHostHeader"
    response_headers_policy_name = "pgs-cors"
    compress                     = true
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
    bucket = module.pgs_log_bucket.s3_bucket_bucket_domain_name
    prefix = "cloudfront/static"
  }
}


data "aws_canonical_user_id" "current" {}
data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

module "pgs_log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v4.5.0"

  bucket = "${local.project}-pgs-log"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  grant = [{
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_canonical_user_id.current.id
    }, {
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id
    # Ref. https://github.com/terraform-providers/terraform-provider-aws/issues/12512
    # Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
  }]
  force_destroy = true
}






resource "aws_s3_bucket" "pgs_new" {
  bucket = "revengegames-pgs-prod"

  tags = {
    Name        = "revengegames-pgs-prod"
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




###### New S3 bucket for PG soft clone

resource "aws_s3_bucket" "pgs2" {
  bucket = "revengegames-pgs2-prod"

  tags = {
    Name        = "revengegames-pgs2-prod"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "pgs2" {
  bucket = aws_s3_bucket.pgs2.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "pgs2_public" {
  bucket = aws_s3_bucket.pgs2.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "pgs2_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.pgs2.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.pgs2_public
  ]
}

resource "aws_s3_bucket_policy" "pgs2_allow_public_access" {
  bucket = aws_s3_bucket.pgs2.id
  policy = data.aws_iam_policy_document.pgs2_s3_allow_public_access.json
}




module "cloudfront_pgs2" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = ["static.pgs.rg-aslgna.com", "m.pgs.rg-aslgna.com"]
  comment = "CloudFront for PG soft clone (prod-test)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:211125478834:certificate/fa1390c8-7ffb-498f-a6de-ebfe3f0a044b"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  origin = {
    s3 = {
      domain_name = "${aws_s3_bucket_website_configuration.pgs2.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id             = "s3"
    allowed_methods              = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods               = ["HEAD", "GET", "OPTIONS"]
    viewer_protocol_policy       = "allow-all"
    use_forwarded_values         = false
    cache_policy_name            = "Managed-CachingDisabled"
    origin_request_policy_name   = "Managed-AllViewerExceptHostHeader"
    response_headers_policy_name = "pgs-cors"
    compress                     = true
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

}