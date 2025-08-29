
data "aws_secretsmanager_secret" "prod_pg_server_env" {
  name = "${local.environment}/pg-server/env"
}
data "aws_secretsmanager_secret" "prod_pg_demo_merchant_server_env" {
  name = "${local.environment}/pg-demo-merchant-server/env"
}

data "cloudflare_zone" "root" {
  name = local.root_domain
}