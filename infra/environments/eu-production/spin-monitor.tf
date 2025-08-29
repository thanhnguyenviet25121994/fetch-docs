module "prd_eu_lambda_spin_monitor" {
  source  = "../../modules/spin-monitor"
  app_env = local.environment
  network_configuration = {
    vpc_id = module.prd_eu_networking.vpc.id
    subnets = [
      module.prd_eu_networking.subnet_private_1.id,
      module.prd_eu_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prd_eu_networking.vpc.default_security_group_id
    ]
  }
  log_bucket_name = "alb-revengegames-prd-eu"
  aws_region      = local.region
}
