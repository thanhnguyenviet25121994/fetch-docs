resource "aws_s3_bucket" "ca" {
  bucket = "ca.dev.revenge-games.com"

  tags = {
    Name        = "revengegames-ca-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "ca" {
  bucket = aws_s3_bucket.ca.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "ca_public" {
  bucket = aws_s3_bucket.ca.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "ca_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.ca.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.ca_public
  ]
}

resource "aws_s3_bucket_policy" "ca_allow_public_access" {
  bucket = aws_s3_bucket.ca.id
  policy = data.aws_iam_policy_document.ca_s3_allow_public_access.json
}


resource "cloudflare_record" "ca" {
  zone_id = data.cloudflare_zone.root.id
  name    = "ca.dev"
  type    = "CNAME"
  content = module.cloudfront_ca.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

module "cloudfront_ca" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = [aws_s3_bucket.ca.bucket]
  comment = "CloudFront for Casual games (dev)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:211125478834:certificate/3f39864d-4f1e-4303-86ca-6720fd434880"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  origin = {
    s3 = {
      domain_name = "${aws_s3_bucket_website_configuration.ca.website_endpoint}"
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
    elb_config = {
      domain_name = "${aws_lb.dev.dns_name}"
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
    allowed_methods              = ["HEAD", "GET"]
    cached_methods               = ["HEAD", "GET"]
    viewer_protocol_policy       = "allow-all"
    use_forwarded_values         = false
    cache_policy_name            = "Managed-CachingDisabled"
    origin_request_policy_name   = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
    response_headers_policy_name = "Managed-CORS-With-Preflight"
    compress                     = true
  }

  ordered_cache_behavior = [
    {
      path_pattern               = "/api/*"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods             = ["HEAD", "GET"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },

    {
      path_pattern               = "/*/config.json"
      target_origin_id           = "elb_config"
      allowed_methods            = ["HEAD", "GET", "OPTIONS"]
      cached_methods             = ["HEAD", "GET", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true


    },
    {
      path_pattern               = "/*/version.json"
      target_origin_id           = "s3"
      allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods             = ["HEAD", "GET"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/*/index.html"
      target_origin_id           = "s3"
      allowed_methods            = ["HEAD", "GET"]
      cached_methods             = ["HEAD", "GET"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
      compress                   = true
    },
    {
      path_pattern               = "/ws"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "GET"]
      cached_methods             = ["HEAD", "GET"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/com.revenge.entity.v1.PlayService"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "GET"]
      cached_methods             = ["HEAD", "GET"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    }
  ]
}

resource "aws_lb_listener_rule" "dev_service_game_client_ca" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 250

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev_service_game_client.arn
  }

  condition {
    host_header {
      values = ["ca.dev.${local.root_domain}"]
    }
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  tags = {
    Name        = "ca.${local.root_domain}"
    Environment = "${local.environment}"
  }
}



