# data "aws_ecr_image" "portal_management" {
#  repository_name = "revengegames/portal-magement"
#  most_recent     = true
# }

# module "snb_eu_portal_management" {
#   source = "../../modules/game"
#   providers = {
#     aws = aws.current
#   }

#   app_env    = local.environment
#   app_name   = "bo"
#   api_url    = "https://api.${local.environment}.${local.root_domain}"
#   assets_url = "https://assets.${local.environment}.${local.root_domain}"
#   domain     = "bo.${local.environment}.${local.root_domain}"
#   cloudfront_distribution_domain_name = ""
# }


# module "snb_eu_portal_replay" {
#  source = "../../modules/portal-replay"
#  providers = {
#    aws = aws.current
#  }

#  app_env   = local.environment
#  domain    = "replay.sandbox.${local.root_domain}"
#  image     = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/portal-replay:${local.portal_replay_version}"
#  value_dns = aws_lb.snb_eu.dns_name
#  app_dns   = "replay.sandbox.${local.root_domain}"
#  role      = aws_iam_role.snb_eu_service

#  network_configuration = {
#    region = "${local.region}"
#    vpc    = module.snb_eu_networking.vpc
#    subnets = [
#      module.snb_eu_networking.subnet_private_1.id,
#      module.snb_eu_networking.subnet_private_2.id
#    ]
#    security_groups = [
#      module.snb_eu_networking.vpc.default_security_group_id
#    ]
#    load_balancer = aws_lb.snb_eu
#  }

#  depends_on = [
#    aws_iam_role.snb_eu_service,
#    aws_iam_role_policy.snb_eu_service_policy,
#  ]
# }

# module "snb_eu_portal_bo" {
#  source = "../../modules/portal-bo"

#  app_env             = local.environment
#  app_domain          = "eubo.sandbox.${local.root_domain}"
#  app_name            = "bo"
#  alb_dns_name        = aws_lb.snb_eu.dns_name
#  lambda_edge_arn     = "arn:aws:lambda:eu-west-1:211125478834:function:bo-sandbox-edge-router:1"
#  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/841855e5-a839-473c-89d6-9ec008a509a2"
# }

# resource "cloudflare_record" "snb_eu_portal_bo" {
#  zone_id = data.cloudflare_zone.root.id
#  name    = "bo.sandbox"
#  content = module.snb_eu_portal_bo.cloudfront_distribution_domain_name
#  type    = "CNAME"
#  proxied = false
# }
