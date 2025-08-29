module "rtp_batch_job" {
  source = "../../modules/rtp-batch-job"

  app_name = "logic-rtp"
  prefix   = local.environment

  vpc_id    = module.dev_networking.vpc.id
  subnet_id = module.dev_networking.subnet_private_1.id

  batch_configs = {
    # name            = "logic-rtp"
    type      = "FARGATE"
    image     = "nginx"
    max_vcpus = 2048
    vcpu      = "2.0"
    memory    = "4096"
  }

}

module "crawl_batch_job" {
  source = "../../modules/rtp-batch-job"

  app_name = "logic-crawl"
  prefix   = local.environment

  vpc_id    = module.dev_networking.vpc.id
  subnet_id = module.dev_networking.subnet_public_1.id

  batch_configs = {
    name      = "logic-crawl"
    type      = "FARGATE"
    image     = "nginx"
    max_vcpus = 256
    vcpu      = "2.0"
    memory    = "4096"
  }

}