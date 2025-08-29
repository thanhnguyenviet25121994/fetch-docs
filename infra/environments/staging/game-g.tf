
###################
#### revenge-games.com
###################
resource "aws_s3_bucket" "g" {
  bucket = "g.sandbox.revenge-games.com"

  tags = {
    Name        = "g.sandbox.revenge-games.com"
    Environment = "sandbox"
  }
}

resource "aws_s3_bucket_website_configuration" "g" {
  bucket = aws_s3_bucket.g.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "g" {
  bucket = aws_s3_bucket.g.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "g_s3_policy" {

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
      "${aws_s3_bucket.g.arn}/*",
    ]
  }

}

resource "aws_s3_bucket_policy" "g_bucket_policy" {
  bucket = aws_s3_bucket.g.id
  policy = data.aws_iam_policy_document.g_s3_policy.json
}



module "sandbox_g_cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  #   providers = {
  #     aws = aws.us-east-1
  #   }

  aliases = ["g.sandbox.revenge-games.com"]

  comment             = "Cloufront for game g"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  # create_origin_access_control = true
  # origin_access_control = {
  #   s3_sandbox_g = {
  #     description      = "CloudFront access to S3"
  #     origin_type      = "s3"
  #     signing_behavior = "always"
  #     signing_protocol = "sigv4"
  #   }
  # }

  origin = {
    s3_sandbox_g = {
      domain_name = "${aws_s3_bucket_website_configuration.g.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    alb_sandbox_g = {
      domain_name = "${aws_lb.staging.dns_name}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    "alb_sandbox_g - /api/v1/client (config.json, env-config.js)" = {
      domain_name = "${aws_lb.staging.dns_name}"
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
    target_origin_id             = "s3_sandbox_g"
    allowed_methods              = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods               = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy       = "redirect-to-https"
    use_forwarded_values         = false
    cache_policy_name            = "Managed-CachingDisabled"
    origin_request_policy_id     = "33f36d7e-f396-46d9-90e0-52428a34d9dc" # "AllViewerAndCloudFrontHeaders-2022-06"
    response_headers_policy_name = "Managed-CORS-With-Preflight"
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
      target_origin_id             = "s3_sandbox_g"
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
      target_origin_id           = "s3_sandbox_g"
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
    },
    {
      path_pattern           = "/*/config.json"
      target_origin_id       = "alb_sandbox_g - /api/v1/client (config.json, env-config.js)"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      use_forwarded_values = false

      cache_policy_name          = "UseOriginCacheControlHeaders-QueryStrings"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },
    {
      path_pattern           = "/*/env-config.js"
      target_origin_id       = "alb_sandbox_g - /api/v1/client (config.json, env-config.js)"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },
    {
      path_pattern           = "/*/env-config.*.js"
      target_origin_id       = "alb_sandbox_g - /api/v1/client (config.json, env-config.js)"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true


    },
    {
      path_pattern           = "/*/client-env"
      target_origin_id       = "alb_sandbox_g"
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
      target_origin_id       = "alb_sandbox_g"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true


    },

    {
      path_pattern           = "/api/*"
      target_origin_id       = "alb_sandbox_g"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },
    {
      path_pattern           = "/*/spin"
      target_origin_id       = "alb_sandbox_g"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },
    {
      path_pattern           = "/*/config"
      target_origin_id       = "alb_sandbox_g"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },

    {
      path_pattern           = "/*/version.json"
      target_origin_id       = "s3_sandbox_g"
      viewer_protocol_policy = "allow-all"

      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    }
  ]

  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:211125478834:certificate/841855e5-a839-473c-89d6-9ec008a509a2"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

}


resource "cloudflare_record" "sandbox_g" {
  zone_id = data.cloudflare_zone.root.id
  name    = "g.sandbox"
  content = module.sandbox_g_cloudfront.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}




#######################
#### all-star.games


module "sandbox_allstar_game" {
  source = "../../modules/game-g"

  alb_dns_name = aws_lb.staging.dns_name

  app_env         = "sandbox"
  app_name        = "allstar_game"
  domain          = local.allstar_domain
  lambda_edge_arn = "arn:aws:lambda:us-east-1:211125478834:function:sandbox-astar-edge-router:13"
  cloudflare_id   = data.cloudflare_zone.allstar.id
}



#######################
#### rectangle_game

module "sandbox_rectangle_games" {
  source = "../../modules/rectangle-game"

  alb_dns_name = aws_lb.staging.dns_name

  app_env         = "sandbox"
  app_name        = "rectangle_game"
  domain          = local.rectangle_domain
  lambda_edge_arn = "arn:aws:lambda:us-east-1:211125478834:function:sandbox-rectangle-edge-router:24"
  cloudflare_id   = data.cloudflare_zone.rectangle.id
}


#######################
#### launcher

module "sandbox_launcher" {
  source = "../../modules/launcher-new"

  alb_dns_name = aws_lb.staging.dns_name

  app_env             = "sandbox"
  app_name            = "launcher"
  app_domain          = "launcher.sandbox.revenge-games.com"
  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/841855e5-a839-473c-89d6-9ec008a509a2"
  lambda_edge_arn     = "arn:aws:lambda:us-east-1:211125478834:function:sandbox-launcher-edge-router:11"
}

resource "cloudflare_record" "portal_launcher" {
  zone_id = data.cloudflare_zone.root.id
  name    = "launcher.sandbox"
  content = module.sandbox_launcher.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}

#######################
#### launcher all star

module "sandbox_astar_launcher" {
  source = "../../modules/astar-launcher"

  alb_dns_name = aws_lb.staging.dns_name

  app_env             = "sandbox"
  app_name            = "launcher"
  app_domain          = "launcher.sandbox.all-star.games"
  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/3c13b5ff-ee5c-41dd-a5ba-ec615e759315"
  lambda_edge_arn     = "arn:aws:lambda:us-east-1:211125478834:function:sandbox-launcher-edge-router:11"
}

resource "cloudflare_record" "portal_astar_launcher" {
  zone_id = data.cloudflare_zone.allstar.id
  name    = "launcher.sandbox"
  content = module.sandbox_astar_launcher.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}


#######################
#### launcher rectangle

module "sandbox_rectangle_launcher" {
  source = "../../modules/rectangle-launcher"

  alb_dns_name = aws_lb.staging.dns_name

  app_env             = "sandbox"
  app_name            = "launcher"
  app_domain          = "launcher.sandbox.rectangle-games.com"
  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/00fe29c1-85f8-4db0-9f36-a6fa0f293742"
  lambda_edge_arn     = "arn:aws:lambda:us-east-1:211125478834:function:sandbox-launcher-edge-router:8"
}

resource "cloudflare_record" "portal_rectangle_launcher" {
  zone_id = data.cloudflare_zone.rectangle.id
  name    = "launcher.sandbox"
  content = module.sandbox_rectangle_launcher.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}