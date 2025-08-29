resource "aws_s3_bucket" "studio" {
  bucket = "studio.sandbox.revenge-games.com"

  tags = {
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "studio" {
  bucket = aws_s3_bucket.studio.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "studio" {
  bucket = aws_s3_bucket.studio.bucket

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
      "${aws_s3_bucket.studio.arn}/*",
    ]
  }

}

resource "aws_s3_bucket_policy" "studio_bucket_policy" {
  bucket = aws_s3_bucket.studio.id
  policy = data.aws_iam_policy_document.studio_s3_policy.json
}



module "staging_studio_cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  #   providers = {
  #     aws = aws.us-east-1
  #   }

  aliases = ["studio.sandbox.revenge-games.com"]

  comment             = "${local.environment} Cloufront for game clone studio"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  # create_origin_access_control = true
  # origin_access_control = {
  #   s3_staging_studio = {
  #     description      = "CloudFront access to S3"
  #     origin_type      = "s3"
  #     signing_behavior = "always"
  #     signing_protocol = "sigv4"
  #   }
  # }

  origin = {
    s3_staging_studio = {
      domain_name = "${aws_s3_bucket_website_configuration.studio.website_endpoint}"
      # origin_access_control = "s3_staging_studio"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    alb_staging = {
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
    target_origin_id             = "s3_staging_studio"
    allowed_methods              = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods               = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy       = "redirect-to-https"
    use_forwarded_values         = false
    cache_policy_name            = "Managed-CachingOptimized"
    origin_request_policy_name   = "Managed-AllViewerExceptHostHeader"
    response_headers_policy_name = "Managed-SimpleCORS"
    compress                     = true

    # response_headers_policy_name = "Managed-CORS-With-Preflight"
    # lambda_function_association = {

    #   origin-request = {
    #     lambda_arn = "arn:aws:lambda:us-east-1:211125478834:function:test-router:5"
    #   }
    # }
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/api/*"
      target_origin_id       = "alb_staging"
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
      target_origin_id       = "s3_staging_studio"
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
      target_origin_id       = "alb_staging"
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
      target_origin_id       = "alb_staging"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

      lambda_function_association = {

        origin-request = {
          lambda_arn = "arn:aws:lambda:us-east-1:211125478834:function:studio-sbox-edge-router:1"
        }
      }
    },
    {
      path_pattern           = "/version.json"
      target_origin_id       = "s3_staging_studio"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerExceptHostHeader"
      compress                   = true
    },
    {
      path_pattern           = "/locales/*"
      target_origin_id       = "s3_staging_studio"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "DELETE", "OPTIONS", "PATCH", "POST", "PUT"]
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
    acm_certificate_arn      = "arn:aws:acm:us-east-1:211125478834:certificate/841855e5-a839-473c-89d6-9ec008a509a2"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

}


resource "cloudflare_record" "staging_studio" {
  zone_id = data.cloudflare_zone.root.id
  name    = "studio.sandbox"
  content = module.staging_studio_cloudfront.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}




###########
## lobby
#######################
#### all-star.games


module "sandbox_lobby" {
  source = "../../modules/lobby"


  app_env             = "sandbox"
  app_name            = "allstar_game"
  domain              = local.allstar_domain
  alb_dns_name        = aws_lb.staging.dns_name
  cloudflare_id       = data.cloudflare_zone.allstar.id
  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/3c13b5ff-ee5c-41dd-a5ba-ec615e759315"
}


module "sandbox_rectangle_lobby" {
  source = "../../modules/lobby"


  app_env             = "sandbox"
  app_name            = "rectangle_game"
  domain              = local.rectangle_domain
  alb_dns_name        = aws_lb.staging.dns_name
  cloudflare_id       = data.cloudflare_zone.rectangle.id
  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/00fe29c1-85f8-4db0-9f36-a6fa0f293742"
}