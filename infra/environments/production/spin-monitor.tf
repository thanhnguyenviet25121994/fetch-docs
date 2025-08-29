module "prod_lambda_spin_monitor" {
  source  = "../../modules/spin-monitor"
  app_env = local.environment
  network_configuration = {
    vpc_id = module.prod_networking.vpc.id
    subnets = [
      module.prod_networking.subnet_private_1.id,
      module.prod_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prod_networking.vpc.default_security_group_id
    ]
  }
  log_bucket_name = "alb-revengegames-prod"
  aws_region      = local.region
}
