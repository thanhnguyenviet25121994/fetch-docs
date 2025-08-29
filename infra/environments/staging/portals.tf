data "aws_ecr_image" "portal_management" {
  repository_name = "revengegames/portal-magement"
  most_recent     = true
}

module "staging_portal_bo" {
  source = "../../modules/portal-bo"

  app_env             = local.environment
  app_domain          = "bo.sandbox.${local.root_domain}"
  app_name            = "bo"
  alb_dns_name        = aws_lb.staging.dns_name
  lambda_edge_arn     = "arn:aws:lambda:us-east-1:211125478834:function:bo-sandbox-edge-router:1"
  acm_certificate_arn = "arn:aws:acm:us-east-1:211125478834:certificate/841855e5-a839-473c-89d6-9ec008a509a2"
}

resource "cloudflare_record" "staging_portal_bo" {
  zone_id = data.cloudflare_zone.root.id
  name    = "bo.sandbox"
  content = module.staging_portal_bo.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = false
}


####################
## portal-operator-2
####################

# resource "cloudflare_record" "portal_operator_2" {
#   zone_id = data.cloudflare_zone.pxplay.id
#   name    = "op"
#   content = aws_lb.staging.dns_name
#   type    = "CNAME"
#   proxied = false
# }
data "aws_secretsmanager_secret" "staging_service_operator_2" {
  name = "${local.environment}/service-portal-operator-2/credentials"
}

module "portal_operator_2" {
  source = "../../modules/portal-operator-2"
  providers = {
    aws = aws.current
  }

  app_env = local.environment
  domain  = "op.${local.pxplay_domain}"
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/portal-operator-2:v1.0.653.1"
  role    = aws_iam_role.staging_service

  env = {
    "DATABASE_DIALECT" : "postgres",
    "LOG_LEVEL" : "DEBUG",
    "CLICKHOUSE_URL" : "http://10.10.61.189:8123",
    "CLICKHOUSE_USERNAME" : "default",
    "CLICKHOUSE_DATABASE" : "operator_portal",
    "SGC_HOST" : "https://api.sandbox.revenge-games.com",
    "NODE_ENV" : "production",
    "PORT" : 3000,
    "PROMOTION_URL" : "https://promotion.sandbox.revenge-games.com",
    "PROMOTION_HOST_NAME" : "promotion.sandbox.revenge-games.com",
    "LOG_LEVEL" : "ERROR"
  }

  secrets = {
    credentials = data.aws_secretsmanager_secret.staging_service_operator_2
  }
  network_configuration = {
    region = "${local.region}"
    vpc    = module.staging_networking.vpc
    subnets = [
      module.staging_networking.subnet_private_1.id,
      module.staging_networking.subnet_private_2.id
    ]
    security_groups = [
      module.staging_networking.vpc.default_security_group_id
    ]
    load_balancer = aws_lb.staging
  }

  depends_on = [
    aws_iam_role.staging_service,
    aws_iam_role_policy.staging_service_policy,
  ]
}
