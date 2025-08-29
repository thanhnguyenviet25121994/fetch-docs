locals {
  default_env_logic_services = [
    {
      name  = "DEFAULT_RTP_PROFILE"
      value = "version_96"
    },
    {
      name  = "LOG_LEVEL"
      value = "debug"
    }
  ]
  env_logic_ver97 = [
    {
      name  = "DEFAULT_RTP_PROFILE"
      value = "version_97"
    },
    {
      name  = "LOG_LEVEL"
      value = "debug"
    }
  ]
  env_logic_b3 = [
    {
      name  = "DEFAULT_RTP_PROFILE"
      value = "B3"
    },
    {
      name  = "LOG_LEVEL"
      value = "debug"
    }
  ]
}



#####

# module "dev_service_game_logic" {
#   source = "../../modules/service-game-logic"

#   providers = {
#     aws = aws.current
#   }

#   app_env = local.environment
#   image   = ""

#   role = aws_iam_role.dev_service
#   network_configuration = {
#     vpc    = module.dev_networking.vpc
#     region = "${local.region}"
#     subnets = [
#       module.dev_networking.subnet_private_1.id,
#       module.dev_networking.subnet_private_2.id
#     ]
#     security_groups = [
#       module.dev_networking.vpc.default_security_group_id
#     ]
#     load_balancer_target_groups = [
#       # aws_lb_target_group.dev_service_game_logic
#     ]
#   }

#   public_routes = {
#     enabled                = true
#     root_domain            = local.dev_root_domain
#     load_balancer_listener = aws_lb_listener.http
#   }

#   services = {
#     lib-logic-remote-math-engine = {
#       image = "${module.ecrs_logic.repository_url_map["revengegames/lib-logic-remote-math-engine"]}:v1.0.1.1"
#       env   = local.default_env_logic_services
#       port = 4772

#     }
#   }
# }


##############
### ECR
##############
locals {
  ecr_repos_logic = [
    "revengegames/lib-logic-remote-math-engine"
  ]
}
module "ecrs_logic" {
  source  = "cloudposse/ecr/aws"
  version = "0.38.0"

  namespace = local.project
  stage     = local.environment
  name      = "app"

  image_names          = [for item in local.ecr_repos_logic : "${item}"]
  image_tag_mutability = "MUTABLE"
  max_image_count      = 100
  scan_images_on_push  = false
  force_delete         = true
}