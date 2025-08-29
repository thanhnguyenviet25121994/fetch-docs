resource "aws_s3_bucket" "hacksaw" {
  bucket = "static.${local.hacksaw_domain}"

  tags = {
    Name        = "revengegames-hacksaw"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "hacksaw" {
  bucket = aws_s3_bucket.hacksaw.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "hacksaw_public" {
  bucket = aws_s3_bucket.hacksaw.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "hacksaw_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.hacksaw.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.hacksaw_public
  ]
}

resource "aws_s3_bucket_policy" "hacksaw_allow_public_access" {
  bucket = aws_s3_bucket.hacksaw.id
  policy = data.aws_iam_policy_document.hacksaw_s3_allow_public_access.json
}



resource "cloudflare_record" "apihacksaw" {
  zone_id = data.cloudflare_zone.hacksaw.id
  name    = "api"
  type    = "CNAME"
  content = "af88f7c2d37bfb364.awsglobalaccelerator.com"
  proxied = true

  allow_overwrite = true
}

resource "cloudflare_record" "statichacksaw" {
  zone_id = data.cloudflare_zone.hacksaw.id
  name    = "static"
  type    = "CNAME"
  content = module.cloudfront_hacksaw.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

module "cloudfront_hacksaw" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = [aws_s3_bucket.hacksaw.bucket]
  comment = "CloudFront for Hacksaw Gaming clone (prod)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = module.hacksaw_acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  origin = {
    s3 = {
      domain_name = "${aws_s3_bucket_website_configuration.hacksaw.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    elb = {
      domain_name = "${aws_lb.prod.dns_name}"
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
    allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods             = ["HEAD", "GET", "OPTIONS"]
    viewer_protocol_policy     = "allow-all"
    use_forwarded_values       = false
    cache_policy_name          = "Managed-CachingDisabled"
    origin_request_policy_name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
    compress                   = true
  }

  ordered_cache_behavior = [
    # {
    #   path_pattern               = "/api/*"
    #   target_origin_id           = "elb"
    #   allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    #   cached_methods             = ["HEAD", "GET", "OPTIONS"]
    #   viewer_protocol_policy     = "allow-all"
    #   use_forwarded_values       = false
    #   cache_policy_name          = "Managed-CachingDisabled"
    #   origin_request_policy_name = "Managed-AllViewer"
    #   compress                   = true
    # },
    # {
    #   path_pattern               = "/health-check"
    #   target_origin_id           = "elb"
    #   allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    #   cached_methods             = ["HEAD", "GET", "OPTIONS"]
    #   viewer_protocol_policy     = "allow-all"
    #   use_forwarded_values       = false
    #   cache_policy_name          = "Managed-CachingDisabled"
    #   origin_request_policy_name = "Managed-AllViewer"
    #   compress                   = true
    # },
    # {
    #   path_pattern               = "/favicon.ico"
    #   target_origin_id           = "elb"
    #   allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    #   cached_methods             = ["HEAD", "GET", "OPTIONS"]
    #   viewer_protocol_policy     = "allow-all"
    #   use_forwarded_values       = false
    #   cache_policy_name          = "Managed-CachingDisabled"
    #   origin_request_policy_name = "Managed-AllViewer"
    #   compress                   = true
    # },
  ]
}
