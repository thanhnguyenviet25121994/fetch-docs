locals {
  pgs_domain = "pgs.lnga-rg.com"
}




# #################################
# ###### m.eu
# ################################
# resource "aws_s3_bucket" "mpgs_eu" {
#   bucket = "m.eu.${local.pgs_dns}"

#   tags = {
#     Name        = "m-pgs-prod-eu"
#     Environment = local.environment
#   }
# }

# resource "aws_s3_bucket_website_configuration" "mpgs_eu" {
#   bucket = aws_s3_bucket.mpgs_eu.id

#   index_document {
#     suffix = "index.html"
#   }

#   error_document {
#     key = "error.html"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "mpgs_eu_public" {
#   bucket = aws_s3_bucket.mpgs_eu.bucket

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }

# data "aws_iam_policy_document" "mpgs_eu_s3_allow_public_access" {
#   statement {
#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }

#     actions = [
#       "s3:GetObject"
#     ]

#     resources = [
#       "${aws_s3_bucket.mpgs_eu.arn}/*",
#     ]
#   }

#   depends_on = [
#     aws_s3_bucket_public_access_block.mpgs_eu_public
#   ]
# }

# resource "aws_s3_bucket_policy" "mpgs_eu_allow_public_access" {
#   bucket = aws_s3_bucket.mpgs_eu.id
#   policy = data.aws_iam_policy_document.mpgs_eu_s3_allow_public_access.json
# }


# resource "cloudflare_record" "mpgs_eu" {
#   zone_id = data.cloudflare_zone.pgs.id
#   name    = "m.eu"
#   type    = "CNAME"
#   content = module.cloudfront_mpgs_eu.cloudfront_distribution_domain_name
#   proxied = true

#   allow_overwrite = true
# }


# module "cloudfront_mpgs_eu" {
#   source  = "terraform-aws-modules/cloudfront/aws"
#   version = "v3.4.0"

#   aliases = [aws_s3_bucket.mpgs_eu.bucket]
#   comment = "CloudFront for PG soft clone (prod-eu)"

#   enabled             = true
#   is_ipv6_enabled     = true
#   retain_on_delete    = false
#   wait_for_deployment = false

#   default_root_object = "index.html"

#   viewer_certificate = {
#     acm_certificate_arn      = module.pgs_eu_acm.acm_certificate_arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2021"
#   }

#   origin = {
#     s3 = {
#       domain_name = "${aws_s3_bucket_website_configuration.mpgs_eu.website_endpoint}"
#       custom_origin_config = {
#         http_port              = 80
#         https_port             = 443
#         origin_protocol_policy = "http-only"
#         origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
#       }
#     }
#     elb = {
#       domain_name = "${aws_lb.prd_eu.dns_name}"
#       custom_origin_config = {
#         http_port              = 80
#         https_port             = 443
#         origin_protocol_policy = "http-only"
#         origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
#       }
#     }
#   }

#   default_cache_behavior = {
#     target_origin_id           = "s3"
#     allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
#     cached_methods             = ["HEAD", "GET", "OPTIONS"]
#     viewer_protocol_policy     = "allow-all"
#     use_forwarded_values       = false
#     cache_policy_name          = "Managed-CachingDisabled"
#     origin_request_policy_name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
#     compress                   = true
#   }

#   ordered_cache_behavior = [

#     {
#       path_pattern           = "/health-check"
#       target_origin_id       = "elb"
#       viewer_protocol_policy = "allow-all"

#       allowed_methods = ["GET", "HEAD", "OPTIONS"]
#       cached_methods  = ["GET", "HEAD", "OPTIONS"]

#       use_forwarded_values = false

#       cache_policy_name          = "Managed-CachingDisabled"
#       origin_request_policy_name = "Managed-AllViewer"
#       compress                   = true
#     },
#     {
#       path_pattern                 = "/shared/service-worker/sw.js"
#       target_origin_id             = "s3"
#       allowed_methods              = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
#       cached_methods               = ["HEAD", "GET", "OPTIONS"]
#       viewer_protocol_policy       = "allow-all"
#       use_forwarded_values         = false
#       cache_policy_name            = "Managed-CachingDisabled"
#       origin_request_policy_name   = "Managed-CORS-S3Origin"
#       response_headers_policy_name = "sw-pgs"
#       compress                     = true
#     },
#   ]
# }