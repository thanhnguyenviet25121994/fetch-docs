module "valkey_serverless" {
  source  = "terraform-aws-modules/elasticache/aws//modules/serverless-cache"
  version = "v1.2.4"

  engine     = "valkey"
  cache_name = "${local.environment}-valkey"

  cache_usage_limits = {
    data_storage = {
      maximum = 2
    }
    ecpu_per_second = {
      maximum = 1000000
    }
  }

  daily_snapshot_time  = "22:00"
  description          = "${local.environment} valkey serverless cluster"
  major_engine_version = "8"
  security_group_ids = [
    module.staging_networking.vpc.default_security_group_id
  ]

  snapshot_retention_limit = 7
  subnet_ids = [
    module.staging_networking.subnet_private_1.id,
    module.staging_networking.subnet_private_2.id
  ]

  #   user_group_id = module.cache_user_group.group_id
}


module "service_game_crash_valkey" {
  source  = "terraform-aws-modules/elasticache/aws//modules/serverless-cache"
  version = "v1.2.4"

  engine     = "valkey"
  cache_name = "${local.environment}-sgcrash-valkey"

  cache_usage_limits = {
    data_storage = {
      maximum = 5
    }
    ecpu_per_second = {
      maximum = 1000000
    }
  }

  daily_snapshot_time  = "22:00"
  description          = "${local.environment} sgcrash valkey serverless cluster"
  major_engine_version = "8"
  security_group_ids = [
    module.staging_networking.vpc.default_security_group_id
  ]

  snapshot_retention_limit = 7
  subnet_ids = [
    module.staging_networking.subnet_private_1.id,
    module.staging_networking.subnet_private_2.id
  ]

  #   user_group_id = module.cache_user_group.group_id
}
