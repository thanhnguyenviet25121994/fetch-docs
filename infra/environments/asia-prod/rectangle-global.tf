resource "aws_s3_bucket" "rcg" {
  bucket = "rcg.${local.rg_domain}"
  tags = {
    Name        = "rectangle-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "rcg" {
  bucket = aws_s3_bucket.rcg.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "rcg_public" {
  bucket = aws_s3_bucket.rcg.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "rcg_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.rcg.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.rcg_public
  ]
}

resource "aws_s3_bucket_policy" "rcg_allow_public_access" {
  bucket = aws_s3_bucket.rcg.id
  policy = data.aws_iam_policy_document.rcg_s3_allow_public_access.json
}


resource "cloudflare_record" "rcg" {
  zone_id = data.cloudflare_zone.rg.id
  name    = "rcg"
  type    = "CNAME"
  content = module.cloudfront_rcg.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

module "cloudfront_rcg" {
  source              = "terraform-aws-modules/cloudfront/aws"
  version             = "v3.4.0"
  aliases             = [aws_s3_bucket.rcg.bucket]
  comment             = "CloudFront for Rectangle games (RC global, prod)"
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
      domain_name = "${aws_s3_bucket_website_configuration.rcg.website_endpoint}"
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
    origin_request_policy_id     = "33f36d7e-f396-46d9-90e0-52428a34d9dc" # "AllViewerAndCloudFrontHeaders-2022-06"
    response_headers_policy_name = "Managed-CORS-With-Preflight"
    compress                     = true
  }

  ordered_cache_behavior = [
    {
      allowed_methods              = ["GET", "HEAD"]
      cache_policy_name            = "Managed-CachingOptimized" # disable cache
      cached_methods               = ["GET", "HEAD"]
      compress                     = true
      default_ttl                  = 0
      max_ttl                      = 0
      min_ttl                      = 0
      origin_request_policy_name   = "Managed-CORS-S3Origin" # CORS-S3Origin
      response_headers_policy_name = "Managed-CORS-With-Preflight"
      path_pattern                 = "/common-assets*"
      smooth_streaming             = false
      target_origin_id             = "s3"
      viewer_protocol_policy       = "allow-all"
      use_forwarded_values         = false
    },
    {
      allowed_methods            = ["GET", "HEAD"]
      cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # disable cache
      cached_methods             = ["GET", "HEAD"]
      compress                   = true
      default_ttl                = 0
      max_ttl                    = 0
      min_ttl                    = 0
      origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # CORS-S3Origin
      response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"
      path_pattern               = "/*/multiple.settings.json"
      smooth_streaming           = false
      target_origin_id           = "s3"
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
    },
    {
      allowed_methods            = ["GET", "HEAD"]
      cache_policy_id            = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad" # disable cache
      cached_methods             = ["GET", "HEAD"]
      compress                   = true
      default_ttl                = 0
      max_ttl                    = 0
      min_ttl                    = 0
      origin_request_policy_id   = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # CORS-S3Origin
      response_headers_policy_id = "5cc3b908-e619-4b99-88e5-2cf7f45965bd"
      path_pattern               = "/*/launcher.settings.json"
      smooth_streaming           = false
      target_origin_id           = "s3"
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
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
      path_pattern           = "/*/env-config.js"
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
      path_pattern           = "/*/env-config.*.js"
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
      path_pattern           = "/client/*"
      target_origin_id       = "elb"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
      compress                   = true

    },
    {
      path_pattern           = "/api/*"
      target_origin_id       = "elb"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
      compress                   = true

    },
    {
      path_pattern           = "/*/spin"
      target_origin_id       = "elb"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
      compress                   = true

    },
    {
      path_pattern           = "/*/config"
      target_origin_id       = "elb"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
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
      origin_request_policy_name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
      compress                   = true

    }
  ]

  logging_config = {
    bucket = module.log_bucket.s3_bucket_bucket_domain_name
    prefix = "cloudfront"
  }
}

module "rcg_log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "rectangle-global-logs"

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

  lifecycle_rule = [
    {
      id      = "expire-logs"
      enabled = true

      expiration = {
        days = 7
      }

      filter = {
        prefix = ""
      }
    }
  ]

  force_destroy = true
}