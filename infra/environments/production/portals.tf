data "aws_ecr_image" "portal_management" {
  repository_name = "revengegames/portal-magement"
  most_recent     = true
}


# module "production_portal_replay" {
#   source = "../../modules/portal-replay"
#   providers = {
#     aws = aws.current
#   }

#   app_env   = local.environment
#   domain    = "replay.rg-lgna.com"
#   image     = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/portal-replay:${local.portal_replay_version}"
#   value_dns = module.prod_cloudfront.cloudfront_distribution_domain_name
#   app_dns   = "replay.rg-lgna.com"
#   role      = aws_iam_role.prod_service

#   network_configuration = {
#     region = "${local.region}"
#     vpc    = module.prod_networking.vpc
#     subnets = [
#       module.prod_networking.subnet_private_1.id,
#       module.prod_networking.subnet_private_2.id
#     ]
#     security_groups = [
#       module.prod_networking.vpc.default_security_group_id
#     ]
#     load_balancer = aws_lb.prod
#   }

#   depends_on = [
#     aws_iam_role.prod_service,
#     aws_iam_role_policy.prod_service_policy,
#   ]
# }



resource "cloudflare_record" "lobby" {
  zone_id = data.cloudflare_zone.root.id
  name    = "lobby"
  value   = module.cloudfront_lobby.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = true
}



module "prod_portal_bo" {
  source = "../../modules/portal-bo"

  app_env             = local.environment
  app_domain          = "bo.${local.root_domain}"
  app_name            = "bo"
  alb_dns_name        = aws_lb.prod.dns_name
  lambda_edge_arn     = "arn:aws:lambda:us-east-1:211125478834:function:bo-prod-edge-router:2"
  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/ed6127af-7d88-4f93-a1a9-ad044a5155b6"
}

resource "cloudflare_record" "prod_portal_bo" {
  zone_id = data.cloudflare_zone.root.id
  name    = "bo"
  content = module.prod_portal_bo.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}



resource "cloudflare_record" "portal_operator_2" {
  zone_id = data.cloudflare_zone.pxplay88.id
  name    = "op"
  value   = aws_lb.prod.dns_name
  type    = "CNAME"
  proxied = true
}
