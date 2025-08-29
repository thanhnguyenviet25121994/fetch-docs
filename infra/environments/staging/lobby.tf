resource "aws_s3_bucket" "lobby" {
  bucket = "lobby.sandbox.${local.root_domain}"

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


module "cloudfront_lobby" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = [aws_s3_bucket.lobby.bucket]
  comment = "CloudFront for Revenge games (sandbox)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:211125478834:certificate/841855e5-a839-473c-89d6-9ec008a509a2"
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





locals {
  alias_lobby         = "pxplaygaming.com"
  pxplaygaming_domain = "pxplaygaming.com"
}

###########
## alias lobby
resource "aws_s3_bucket" "alias_lobby" {
  bucket = local.alias_lobby

  tags = {
    Name        = "${local.alias_lobby}"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "alias_lobby" {
  bucket = aws_s3_bucket.alias_lobby.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "alias_lobby_public" {
  bucket = aws_s3_bucket.alias_lobby.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "alias_lobby_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.alias_lobby.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.alias_lobby_public
  ]
}

resource "aws_s3_bucket_policy" "alias_lobby_allow_public_access" {
  bucket = aws_s3_bucket.alias_lobby.id
  policy = data.aws_iam_policy_document.alias_lobby_s3_allow_public_access.json
}

module "cloudfront_alias_lobby" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = [aws_s3_bucket.alias_lobby.bucket]
  comment = "CloudFront for lobby (pxplaygaming)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:211125478834:certificate/a2b53bd6-f089-49f6-ac85-b60b13c22d7f"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  origin = {
    s3 = {
      domain_name = "${aws_s3_bucket_website_configuration.alias_lobby.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
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
    },
    {
      path_pattern               = "/version.json"
      target_origin_id           = "s3"
      allowed_methods            = ["HEAD", "GET", "OPTIONS"]
      cached_methods             = ["HEAD", "GET", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
  ]
}