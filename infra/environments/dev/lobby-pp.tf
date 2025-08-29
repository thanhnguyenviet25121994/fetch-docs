resource "aws_s3_bucket" "lobby_pp" {
  bucket = "lobby.pp.dev.${local.root_domain}"

  tags = {
    Name        = "revengegames-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "lobby_pp" {
  bucket = aws_s3_bucket.lobby_pp.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "lobby_pp_public" {
  bucket = aws_s3_bucket.lobby_pp.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "lobby_pp_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.lobby_pp.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.lobby_pp_public
  ]
}

resource "aws_s3_bucket_policy" "lobby_pp_allow_public_access" {
  bucket = aws_s3_bucket.lobby_pp.id
  policy = data.aws_iam_policy_document.lobby_pp_s3_allow_public_access.json
}


resource "cloudflare_record" "lobby_pp" {
  zone_id = data.cloudflare_zone.root.id
  name    = "lobby.pp.dev"
  type    = "CNAME"
  content = module.cloudfront_lobby_pp.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

module "cloudfront_lobby_pp" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = [aws_s3_bucket.lobby_pp.bucket]
  comment = "CloudFront for lobby pp (dev)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = module.pp_acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  origin = {
    s3 = {
      domain_name = "${aws_s3_bucket_website_configuration.lobby_pp.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    elb = {
      domain_name = "${aws_lb.dev.dns_name}"
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
    cache_policy_name          = "Managed-CachingDisabled"
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
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    }
  ]
}
