resource "aws_s3_bucket" "backoffice" {
  bucket = "bo.${local.root_domain}"

  tags = {
    Name        = "bo.${local.root_domain}"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "backoffice" {
  bucket = aws_s3_bucket.backoffice.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html" // This is intentional, for client-side routing
  }
}

resource "aws_s3_bucket_public_access_block" "backoffice_public" {
  bucket = aws_s3_bucket.backoffice.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "backoffice_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.backoffice.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.backoffice_public
  ]
}

resource "aws_s3_bucket_policy" "backoffice_allow_public_access" {
  bucket = aws_s3_bucket.backoffice.id
  policy = data.aws_iam_policy_document.backoffice_s3_allow_public_access.json
}



resource "cloudflare_record" "backoffice" {
  zone_id = data.cloudflare_zone.root.id
  name    = "bo"
  type    = "CNAME"
  content = module.cloudfront_backoffice.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

module "cloudfront_backoffice" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = [aws_s3_bucket.backoffice.bucket]
  comment = "CloudFront for BO (Asia, prod)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = module.prod_acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  origin = {
    s3 = {
      domain_name = "${aws_s3_bucket_website_configuration.backoffice.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    elb = {
      domain_name = "${aws_lb.prod_asia.dns_name}"
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
    cache_policy_name          = "Managed-CachingOptimized"
    origin_request_policy_name = "Managed-AllViewer"
    compress                   = true
  }

  ordered_cache_behavior = [
    # {
    #   path_pattern               = "/env-config.js"
    #   target_origin_id           = "s3"
    #   allowed_methods            = ["HEAD", "GET", "OPTIONS"]
    #   cached_methods             = ["HEAD", "GET", "OPTIONS"]
    #   viewer_protocol_policy     = "allow-all"
    #   use_forwarded_values       = false
    #   cache_policy_name          = "Managed-CachingOptimized"
    #   origin_request_policy_name = "Managed-AllViewer"
    #   compress                   = true
    # },
    {
      path_pattern               = "/api/*"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods             = ["HEAD", "GET", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    }
  ]
}
