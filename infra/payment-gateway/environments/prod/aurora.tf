locals {

  preferred_maintenance_window = "sun:05:00-sun:06:00"

  aurora_instance_params = {
    # log_statement                      = "all"
    # log_min_duration_statement         = "5000"
    shared_preload_libraries = "pg_stat_statements,pglogical"

  }

  aurora_instance_parameters = [for k, v in local.aurora_instance_params :
    tomap({
      "apply_method" = "pending-reboot"
      "name"         = "${k}"
      "value"        = "${v}"
    })
  ]

  cluster_params = {
    shared_preload_libraries  = "pg_stat_statements,auto_explain"
    "rds.logical_replication" = "1"
    "synchronous_commit"      = "ON"


  }

  aurora_cluster_parameters = [for k, v in local.cluster_params :
    tomap({
      "apply_method" = "pending-reboot"
      "name"         = "${k}"
      "value"        = "${v}"
    })
  ]
}


data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "15.4"
}



module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "v9.9.0"

  name              = lower("${local.project_name}-${local.environment}-db")
  engine            = data.aws_rds_engine_version.postgresql.engine
  engine_mode       = "provisioned"
  engine_version    = data.aws_rds_engine_version.postgresql.version
  storage_encrypted = false
  master_username   = "sqladmin"

  vpc_id                 = module.vpc.vpc_id
  availability_zones     = module.vpc.azs
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  create_security_group  = false
  vpc_security_group_ids = [module.rds_sg.security_group_id]

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  enable_http_endpoint = true

  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 10
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
  }

  db_parameter_group_name         = module.params_aurora.db_parameter_name
  db_cluster_parameter_group_name = module.params_aurora.cluster_parameter_name
  auto_minor_version_upgrade      = false
  backup_retention_period         = "1"
  preferred_backup_window         = "16:00-17:00"
  preferred_maintenance_window    = "sun:05:00-sun:05:30"

}


module "params_aurora" {
  source = "../../modules/aurora-parameter"

  name                = lower("${local.project_name}-${local.environment}-params-aurora")
  family              = "aurora-postgresql15"
  instance_parameters = local.aurora_instance_parameters
  cluster_parameters  = local.aurora_cluster_parameters

}
