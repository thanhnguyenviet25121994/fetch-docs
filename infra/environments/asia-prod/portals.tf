
####################
## portal-operator-2-internal
####################
data "aws_secretsmanager_secret" "prod_asia_service_operator_2_internal" {
  name = "${local.environment}/service-portal-operator-2-internal/credentials"
}

module "prod_asia_operator_2_internal" {
  source = "../../modules/portal-operator-2"
  providers = {
    aws = aws.current
  }

  app_env  = local.environment
  app_name = "portal-operator-2-internal"
  priority = 29001
  domain   = "op.rectangle-games.com"
  image    = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/portal-operator-2:v1.0.653.1"
  role     = aws_iam_role.prod_asia_service

  env = {
    "DATABASE_DIALECT" : "postgres",
    "LOG_LEVEL" : "ERROR",
    "CLICKHOUSE_URL" : "http://10.90.113.175:8123",
    "CLICKHOUSE_USERNAME" : "default",
    "CLICKHOUSE_DATABASE" : "default",
    "SGC_HOST" : "https://apig.rg-lgna.com",
    "APP_BRANDING" : "RECTANGLE",
    "NODE_ENV" : "production",
    "PORT" : 3000,
    "PROMOTION_URL" : "https://promo-api.rg-lgna.com/",
    "PROMOTION_HOST_NAME" : "promo-api.rg-lgna.com",
    "LOG_LEVEL" : "ERROR"
  }

  secrets = {
    credentials = data.aws_secretsmanager_secret.prod_asia_service_operator_2_internal
  }
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prod_asia_networking.vpc
    subnets = [
      module.prod_asia_networking.subnet_private_1.id,
      module.prod_asia_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prod_asia_networking.vpc.default_security_group_id
    ]
    load_balancer = aws_lb.prod_asia
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
  ]
}



data "aws_secretsmanager_secret" "prod_asia_service_operator_2" {
  name = "${local.environment}/service-portal-operator-2/credentials"
}

module "portal_asia_operator_2" {
  source = "../../modules/portal-operator-2"
  providers = {
    aws = aws.current
  }

  app_env = local.environment
  domain  = "op.pxplay88.com"
  image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/portal-operator-2:v1.0.616.1"
  role    = aws_iam_role.prod_asia_service



  env = {
    "DATABASE_DIALECT" : "postgres",
    "LOG_LEVEL" : "ERROR",
    "CLICKHOUSE_URL" : "http://10.90.113.175:8123",
    "CLICKHOUSE_USERNAME" : "default",
    "CLICKHOUSE_DATABASE" : "default",
    "SGC_HOST" : "https://apig.rg-lgna.com"
    "NODE_ENV" : "production",
    "PORT" : 3000,
    "LOG_LEVEL" : "ERROR"
  }

  secrets = {
    credentials = data.aws_secretsmanager_secret.prod_asia_service_operator_2
  }
  network_configuration = {
    region = "${local.region}"
    vpc    = module.prod_asia_networking.vpc
    subnets = [
      module.prod_asia_networking.subnet_private_1.id,
      module.prod_asia_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prod_asia_networking.vpc.default_security_group_id
    ]
    load_balancer = aws_lb.prod_asia
  }

  depends_on = [
    aws_iam_role.prod_asia_service,
    aws_iam_role_policy.prod_asia_service_policy,
  ]
}
