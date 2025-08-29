data "cloudflare_zone" "root" {
  name = "revenge-games.com"
}

data "aws_secretsmanager_secret" "dev_pg_server_env" {
  name = "${local.environment}/pg-server/env"
}
data "aws_secretsmanager_secret" "dev_pg_demo_merchant_server_env" {
  name = "${local.environment}/pg-demo-merchant-server/env"
}