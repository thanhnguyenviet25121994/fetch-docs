resource "aws_elasticache_serverless_cache" "cache" {
  engine = "valkey"
  name   = "dev-cache"
  cache_usage_limits {
    data_storage {
      maximum = 2
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 5000
    }
  }
  daily_snapshot_time      = "18:00"
  description              = "dev valkey"
  major_engine_version     = "8"
  snapshot_retention_limit = 0
  security_group_ids       = ["sg-068b67fc8a1e16983"]
  subnet_ids               = ["subnet-025c65831bf770a08", "subnet-0b800e465a7531d71"]
}


locals {
  valkey_names = {
    promotion = "${local.environment}-promotion-valkey"
    sgcrash   = "${local.environment}-sgcrash-valkey"

  }
}


module "valkey_serverless" {
  for_each = local.valkey_names

  source  = "terraform-aws-modules/elasticache/aws//modules/serverless-cache"
  version = "v1.2.4"

  engine     = "valkey"
  cache_name = each.value

  cache_usage_limits = {
    data_storage = {
      maximum = 2
    }
    ecpu_per_second = {
      maximum = 5000
    }
  }

  daily_snapshot_time  = "22:00"
  description          = "${each.key} valkey serverless cluster"
  major_engine_version = "8"
  security_group_ids = [
    module.dev_networking.vpc.default_security_group_id
  ]

  snapshot_retention_limit = 7
  subnet_ids = [
    module.dev_networking.subnet_private_1.id,
    module.dev_networking.subnet_private_2.id
  ]

  #   user_group_id = module.cache_user_group.group_id
}
