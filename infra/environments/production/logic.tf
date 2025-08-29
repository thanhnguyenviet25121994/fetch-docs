locals {
  default_env_logic_services = [
    {
      name  = "DEFAULT_RTP_PROFILE"
      value = "version_96"
    },
    {
      name  = "LOG_LEVEL"
      value = "error"
    }
  ]
}
module "prod_service_game_logic" {
  source = "../../modules/service-game-logic"

  providers = {
    aws = aws.current
  }

  app_env = local.environment
  # image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-logic:${local.service_game_logic_version}"

  role = aws_iam_role.prod_service
  network_configuration = {
    vpc    = module.prod_networking.vpc
    region = "${local.region}"
    subnets = [
      module.prod_networking.subnet_private_1.id,
      module.prod_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prod_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = []
  }

  instance_count = {
    min = 2
    max = 32
  }

  public_routes = {
    enabled                = false
    root_domain            = local.root_domain
    load_balancer_listener = aws_lb_listener.http
  }

  services = {}


  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
  ]
}



# # New logic cluster
# module "prd_service_game_logic" {
#   source = "../../modules/prd-service-game-logic"

#   providers = {
#     aws = aws.current
#   }

#   app_env = "prd"
#   image   = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-logic:${local.service_game_logic_version}"

#   role = aws_iam_role.prod_service
#   network_configuration = {
#     vpc    = module.prod_networking.vpc
#     region = "${local.region}"
#     subnets = [
#       module.prod_networking.subnet_private_1.id,
#       module.prod_networking.subnet_private_2.id
#     ]
#     security_groups = [
#       module.prod_networking.vpc.default_security_group_id
#     ]
#     load_balancer_target_groups = []
#   }

#   public_routes = {
#     enabled                = false
#     root_domain            = local.root_domain
#     load_balancer_listener = aws_lb_listener.http
#   }

#   services = {
#     prd-logic-fortune-dragon = {
#       image = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/logic-fortune-dragon:v1.0.92.1"
#     }
#     prd-logic-fortune-ox = {
#       image = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/logic-fortune-ox:v1.0.24.1"
#     },
#   }

#   depends_on = [
#     aws_iam_role.prod_service,
#     aws_iam_role_policy.prod_service_policy,
#   ]
# }
