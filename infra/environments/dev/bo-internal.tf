
module "s3_bo_internal" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket        = "revengegames-bo-internal"
  force_destroy = true

  # acl = "private"

  website = {
    index_document = "index.html"
    error_document = "error.html"
  }
}

data "aws_iam_policy_document" "s3_bo_policy" {
  # Origin Access Identities
  # statement {
  #   actions   = ["s3:GetObject"]
  #   resources = ["${module.s3_bo_internal.s3_bucket_arn}/*"]

  #   principals {
  #     type        = "AWS"
  #     identifiers = module.cloudfront_bo_internal.cloudfront_origin_access_identity_iam_arns
  #   }
  # }

  # Origin Access Controls
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_bo_internal.s3_bucket_arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [module.cloudfront_bo_internal.cloudfront_distribution_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bo_bucket_policy" {
  bucket = module.s3_bo_internal.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_bo_policy.json
}


resource "cloudflare_record" "staticbo_internal" {
  zone_id = data.cloudflare_zone.root.id
  name    = "bo.internal"
  type    = "CNAME"
  content = module.cloudfront_bo_internal.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

module "cloudfront_bo_internal" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = ["bo.internal.revenge-games.com"]
  comment = "CloudFront for bo internal (dev)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = module.rginternal_acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  create_origin_access_control = true
  origin_access_control = {
    s3_oac = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = {

    s3_oac = {
      domain_name           = module.s3_bo_internal.s3_bucket_bucket_regional_domain_name
      origin_access_control = "s3_oac"
    }
  }


  default_cache_behavior = {
    path_pattern           = "*"
    target_origin_id       = "s3_oac"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    query_string           = true
  }

  ordered_cache_behavior = [

  ]
  custom_error_response = [
    {
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    },
    {
      error_code         = 403
      response_code      = 200
      response_page_path = "/index.html"
    }
  ]
}



# #### service
# ##############
# ### service-jili-adapter
# #############
# module "dev_service_rg_internal" {
#   providers = {
#     aws = aws.current
#   }

#   task_size_cpu    = "512"
#   task_size_memory = "1024"

#   app_name = "service-rginternal"

#   source = "../../modules/service-jili-adapter"

#   app_env = local.environment
#   image   = "${module.ecrs.repository_url_map["revengegames/service-rginternal"]}:v1.0.17.1"

#   env = {
#     TZ                    = "Etc/UTC"
#     PORT = "9945"
#     TYPEORM_CONNECTION    = "postgres"
#     TYPEORM_DB_URI        = "postgres://postgres:postgres@localhost:5432/service_internals"
#     SERVICE_ENTITY_DB_URI = "postgres://postgres:postgres@localhost:5432/service_entity"
#     NODE_ENV              = "development"
#     HOSTNAME              = "https://bo.rectangle-games.com:7338"
#     HOSTNAME_API          = "http://localhost:7336"
#     HOSTNAME_ROOT         = "localhost"

#   }

#   role = aws_iam_role.dev_service
#   network_configuration = {
#     region = "${local.region}"
#     vpc    = module.dev_networking.vpc
#     subnets = [
#       module.dev_networking.subnet_private_1.id,
#       module.dev_networking.subnet_private_2.id
#     ]
#     security_groups = [
#       module.dev_networking.vpc.default_security_group_id
#     ]
#     load_balancer_target_groups = [{
#       arn  = aws_lb_target_group.dev_service_rg_internal.arn,
#       port = 9945
#     }]
#   }

#   depends_on = [
#     aws_iam_role.dev_service,
#     aws_iam_role_policy.dev_service_policy,
#   ]
# }

# resource "aws_lb_target_group" "dev_service_rg_internal" {
#   name        = "${local.environment}-service-jili-adapter"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = module.dev_networking.vpc.id
#   target_type = "ip"

#   health_check {
#     path                = "/actuator/health"
#     healthy_threshold   = 5
#     unhealthy_threshold = 10
#   }

#   tags = {
#     Environment = local.environment
#   }
# }

# resource "aws_lb_listener_rule" "dev_service_rg_internal" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 1101

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.dev_service_rg_internal.arn
#   }

#   condition {
#     host_header {
#       values = ["jili.${local.environment}.${local.root_domain}"]
#     }
#   }

#   tags = {
#     Name        = "jili.${local.environment}.${local.root_domain}"
#     Environment = "${local.environment}"
#   }
# }