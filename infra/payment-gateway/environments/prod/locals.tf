locals {
  project_name   = "pg"
  aws_region     = "ap-southeast-1"
  environment    = "prod"
  aws_account_id = "211125478834"
  root_domain    = "revenge-pay.com"

  ############
  ### ECR repo
  ############
  ecr_repos = [
    "revengegames/pg-server",
    "revengegames/pg-demo-merchant-server"
  ]


  #############
  ### VPC env
  ##############
  vpc_cidr                     = "172.20.0.0/16"
  cidr_newbits                 = 6
  create_database_subnet_group = true


  ############
  ## IAM
  ############
  policy_file = "${abspath("${path.module}/../../templates/iam")}/ecs_task_exec.json.tftpl"

}