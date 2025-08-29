resource "aws_s3_bucket" "lobby" {
  bucket = "lobby.lnga-rg.com"

  tags = {
    Name        = "revengegames-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "lobby" {
  bucket = aws_s3_bucket.lobby.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "lobby_public" {
  bucket = aws_s3_bucket.lobby.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "lobby_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.lobby.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.lobby_public
  ]
}

resource "aws_s3_bucket_policy" "lobby_allow_public_access" {
  bucket = aws_s3_bucket.lobby.id
  policy = data.aws_iam_policy_document.lobby_s3_allow_public_access.json
}

module "lobby_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name = aws_s3_bucket.lobby.bucket
  zone_id     = data.cloudflare_zone.root.id

  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.global
  }
}

resource "cloudflare_record" "lobby_acm" {
  for_each = {
    for dvo in module.lobby_acm.validation_domains : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      content = dvo.resource_record_value
    }
  }

  zone_id = data.cloudflare_zone.root.id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
  ttl     = 60
  proxied = false

  allow_overwrite = true
}

resource "cloudflare_record" "lobby" {
  zone_id = data.cloudflare_zone.root.id
  name    = "lobby"
  type    = "CNAME"
  content = module.cloudfront_lobby.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

module "cloudfront_lobby" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = [aws_s3_bucket.lobby.bucket]
  comment = "CloudFront for Revenge games (EU, Production)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = module.lobby_acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  origin = {
    s3 = {
      domain_name = "${aws_s3_bucket_website_configuration.lobby.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    elb = {
      domain_name = "${aws_lb.prd_eu.dns_name}"
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
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    }
  ]
}
