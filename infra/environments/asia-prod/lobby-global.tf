resource "aws_s3_bucket" "lobbyg" {
  bucket = "lobbyg.${local.rg_domain}"

  tags = {
    Name        = "lobbyg.${local.environment}"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "lobbyg" {
  bucket = aws_s3_bucket.lobbyg.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "lobbyg_public" {
  bucket = aws_s3_bucket.lobbyg.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "lobbyg_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.lobbyg.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.lobbyg_public
  ]
}

resource "aws_s3_bucket_policy" "lobbyg_allow_public_access" {
  bucket = aws_s3_bucket.lobbyg.id
  policy = data.aws_iam_policy_document.lobbyg_s3_allow_public_access.json
}


resource "cloudflare_record" "lobbyg" {
  zone_id = data.cloudflare_zone.rg.id
  name    = "lobbyg"
  type    = "CNAME"
  content = module.cloudfront_lobbyg.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

module "cloudfront_lobbyg" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases             = [aws_s3_bucket.lobbyg.bucket]
  comment             = "CloudFront for Revenge games (AS, Production)"
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
      domain_name = "${aws_s3_bucket_website_configuration.lobbyg.website_endpoint}"
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
    {
      path_pattern               = "/api/*"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods             = ["HEAD", "GET", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
      compress                   = true
    }
  ]
}
