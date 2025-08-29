
locals {
  dashboard_vars = {
    region                          = "ap-southeast-1",
    rds_cluster_identifier          = aws_rds_cluster.prod_asia_main.cluster_identifier
    rds_instance_primary_identifier = aws_rds_cluster_instance.prod_asia_main_reader.id
  }
}
resource "aws_cloudwatch_dashboard" "prod_asia" {
  dashboard_name = "PROD-ASIA-DASHBOARD"

  dashboard_body = templatefile("${path.module}/dashboard.json.tpl", local.dashboard_vars)
}