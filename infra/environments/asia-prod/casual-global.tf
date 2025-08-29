resource "aws_s3_bucket" "cag" {
  bucket = "cag.${local.rg_domain}"
  tags = {
    Name        = "revengegames-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "cag" {
  bucket = aws_s3_bucket.cag.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "cag_public" {
  bucket = aws_s3_bucket.cag.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "cag_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.cag.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.cag_public
  ]
}

resource "aws_s3_bucket_policy" "cag_allow_public_access" {
  bucket = aws_s3_bucket.cag.id
  policy = data.aws_iam_policy_document.cag_s3_allow_public_access.json
}


resource "cloudflare_record" "cag" {
  zone_id = data.cloudflare_zone.rg.id
  name    = "cag"
  type    = "CNAME"
  content = module.cloudfront_cag.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

module "cloudfront_cag" {
  source              = "terraform-aws-modules/cloudfront/aws"
  version             = "v3.4.0"
  aliases             = [aws_s3_bucket.cag.bucket]
  comment             = "CloudFront for Revenge games (CA global, prod)"
  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:211125478834:certificate/ed6127af-7d88-4f93-a1a9-ad044a5155b6"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  origin = {
    s3 = {
      domain_name = "${aws_s3_bucket_website_configuration.cag.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    elb = {
      domain_name = "${module.global_accelerator.dns_name}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    elb_config = {
      domain_name = "${module.global_accelerator.dns_name}"
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
    target_origin_id             = "s3"
    allowed_methods              = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods               = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy       = "allow-all"
    use_forwarded_values         = false
    cache_policy_name            = "Managed-CachingOptimized"
    origin_request_policy_name   = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
    response_headers_policy_name = "Managed-CORS-With-Preflight"
    compress                     = true
    viewer_protocol_policy       = "allow-all"
    min_ttl                      = 0
    default_ttl                  = 0
    max_ttl                      = 0
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/api/*"
      target_origin_id       = "elb"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },
    {
      path_pattern           = "/client/*"
      target_origin_id       = "elb"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },
    {
      path_pattern           = "/*/config.json"
      target_origin_id       = "elb_config"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
      compress                   = true

    },
    {
      path_pattern           = "/*/index.html"
      target_origin_id       = "s3"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
      compress                   = true

    },
    {
      path_pattern           = "/*/version.json"
      target_origin_id       = "s3"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/ws"
      target_origin_id       = "elb"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/com.revenge.entity.v1.PlayService"
      target_origin_id           = "elb"
      viewer_protocol_policy     = "allow-all"
      allowed_methods            = ["GET", "HEAD"]
      cached_methods             = ["GET", "HEAD"]
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },
  ]

  logging_config = {
    bucket = module.log_bucket.s3_bucket_bucket_domain_name
    prefix = "cloudfront"
  }
}
