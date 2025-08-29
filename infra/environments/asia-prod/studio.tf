resource "aws_s3_bucket" "prod_studio" {
  bucket = "studio.${local.root_domain}"

  tags = {
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "prod_studio" {
  bucket = aws_s3_bucket.prod_studio.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "prod_studio" {
  bucket = aws_s3_bucket.prod_studio.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "studio_s3_policy" {

  # Origin Access Controls
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.prod_studio.arn}/*",
    ]
  }

}

resource "aws_s3_bucket_policy" "studio_bucket_policy" {
  bucket = aws_s3_bucket.prod_studio.id
  policy = data.aws_iam_policy_document.studio_s3_policy.json
}

module "prod_asia_studio_cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = ["studio.${local.root_domain}"]

  comment             = "${local.environment} Cloufront for studio prod ASIA"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  origin = {
    s3_prod_asia_studio = {
      domain_name = "${aws_s3_bucket_website_configuration.prod_studio.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    alb_prod_asia = {
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
    target_origin_id             = "s3_prod_asia_studio"
    allowed_methods              = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods               = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy       = "redirect-to-https"
    use_forwarded_values         = false
    cache_policy_name            = "Managed-CachingOptimized"
    origin_request_policy_name   = "Managed-AllViewerExceptHostHeader"
    response_headers_policy_name = "Managed-SimpleCORS"
    compress                     = true
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/api/*"
      target_origin_id       = "alb_prod_asia"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/index.html"
      target_origin_id       = "s3_prod_asia_studio"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["HEAD", "GET"]
      cached_methods  = ["GET", "HEAD"]
      default_ttl     = 0
      max_ttl         = 0
      min_ttl         = 0

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerExceptHostHeader"
      compress                   = true
    },
    {
      path_pattern           = "/auth/*"
      target_origin_id       = "alb_prod_asia"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingOptimized"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern           = "/env-config.js"
      target_origin_id       = "alb_prod_asia"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

      # lambda_function_association = {

      #   origin-request = {
      #     lambda_arn = "arn:aws:lambda:us-east-1:211125478834:function:studio-sbox-edge-router:2"
      #   }
      # }
    },
    {
      path_pattern           = "/version.json"
      target_origin_id       = "s3_prod_asia_studio"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerExceptHostHeader"
      compress                   = true
    }
  ]

  custom_error_response = [
    {
      error_caching_min_ttl = 10
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
    }
  ]



  viewer_certificate = {
    acm_certificate_arn      = module.prod_acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

}


# resource "cloudflare_record" "prod_asia_studio" {
#   zone_id = data.cloudflare_zone.root.id
#   name    = "studio.prod"
#   content = module.prod_asia_studio_cloudfront.cloudfront_distribution_domain_name
#   type    = "CNAME"
#   proxied = false
# }
