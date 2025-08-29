locals {
  default_env_logic_services = [
    {
      name  = "DEFAULT_RTP_PROFILE"
      value = "version_96"
    }
  ]
}
# module "mkt_service_game_logic" {
#   source = "../../modules/mkt-service-game-logic"

#   providers = {
#     aws = aws.current
#   }

#   app_env = local.environment
#   image   = ""

#   role = aws_iam_role.mkt_service
#   network_configuration = {
#     vpc    = module.mkt_networking.vpc
#     region = "${local.region}"
#     subnets = [
#       module.mkt_networking.subnet_private_1.id,
#       module.mkt_networking.subnet_private_2.id
#     ]
#     security_groups = [
#       module.mkt_networking.vpc.default_security_group_id
#     ]
#     load_balancer_target_groups = []
#   }

#   public_routes = {
#     enabled                = false
#     root_domain            = local.root_domain
#     load_balancer_listener = aws_lb_listener.http
#   }

#   services = {

#   }

#   depends_on = [
#     aws_iam_role.mkt_service,
#     aws_iam_role_policy.mkt_service_policy,
#   ]


# }
