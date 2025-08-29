data "aws_secretsmanager_secret" "operator_demo_db" {
  name = "${local.environment}/operator-demo/db"
}


resource "cloudflare_record" "operator_demo" {
  zone_id = data.cloudflare_zone.root.id
  name    = "operator-demo"
  content = aws_lb.prd_eu.dns_name
  type    = "CNAME"
  proxied = true
}
