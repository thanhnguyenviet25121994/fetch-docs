# locals {
#   environment_config = {
#     dev = {
#       region             = "ap-southeast-1"
#       vpc_id             = data.terraform_remote_state.dev.outputs.network_info.vpc.id
#       vpc_private_subnet = ["${data.terraform_remote_state.dev.outputs.network_info.subnet_private_1.id}", "${data.terraform_remote_state.dev.outputs.network_info.subnet_private_2.id}"]
#       alb = {
#         alb1 = data.terraform_remote_state.dev.outputs.dev_alb_private_dns_1
#         alb2 = data.terraform_remote_state.dev.outputs.dev_alb_private_dns_2
#         alb3 = data.terraform_remote_state.dev.outputs.dev_alb_private_dns_3
#       }
#     }
#     sandbox = {
#       region             = "ap-northeast-1"
#       vpc_id             = data.terraform_remote_state.staging.outputs.network_info.vpc.id
#       vpc_private_subnet = ["${data.terraform_remote_state.staging.outputs.network_info.subnet_private_1.id}", "${data.terraform_remote_state.staging.outputs.network_info.subnet_private_2.id}"]
#       alb = {
#         alb1 = data.terraform_remote_state.staging.outputs.staging_alb_private_dns_1
#         alb2 = data.terraform_remote_state.staging.outputs.staging_alb_private_dns_2
#         alb3 = data.terraform_remote_state.staging.outputs.staging_alb_private_dns_3
#       }
#     }
#     # prod = {
#     #   vpc_id             = "3"
#     #   vpc_private_subnet = ["7", "8"]
#     #   alb = {
#     #     alb1 = "4"
#     #     alb2 = "5"
#     #   }
#     # }
#     # prd-eu = {
#     #   vpc_id             = "4"
#     #   vpc_private_subnet = ["9", "10"]
#     #   alb = {
#     #     alb1 = "6"
#     #     alb2 = "7"
#     #   }
#     # }
#     # prod-asia = {
#     #   vpc_id             = "5"
#     #   vpc_private_subnet = ["11", "12"]
#     #   alb = {
#     #     alb1 = "8"
#     #     alb2 = ""
#     #   }
#     # }
#   }
# }


# # Configure all required regional providers
# provider "aws" {
#   alias  = "ap_southeast_1"
#   region = "ap-southeast-1"
# }

# provider "aws" {
#   alias  = "ap_northeast_1"
#   region = "ap-northeast-1"
# }

# provider "aws" {
#   alias  = "sa_east_1"
#   region = "sa-east-1"
# }

# provider "aws" {
#   alias  = "eu_west_1"
#   region = "eu-west-1"
# }

# locals {

#   # Single list of services with environment detection
#   lambda_logic_4 = [
#     {
#       name = "logic-jackpot-hunter111-cloned"
#       env = {
#         NODE_ENV            = "production"
#         DEFAULT_RTP_PROFILE = "version_96"
#         VALIDATE_STATE      = true
#         RG_LOG_NATIVE       = true
#       }
#       handler              = "dist/src/main.handler"
#       lambda_architectures = ["arm64"]
#       memory_size          = "256"
#     }
#   ]
# }


# module "staging_lambda_services_4" {
#   source  = "../../../modules/lambda-service-logic-4"
#   app_env = "staging"

#   providers = {
#     aws = aws.ap_northeast_1
#   }
#   network_configuration = {
#     vpc_id = data.terraform_remote_state.staging.outputs.network_info.vpc.id
#     subnets = [
#       data.terraform_remote_state.staging.outputs.network_info.subnet_private_1.id,
#       data.terraform_remote_state.staging.outputs.network_info.subnet_private_2.id
#     ]
#     security_groups = [
#       data.terraform_remote_state.staging.outputs.network_info.vpc.default_security_group_id
#     ]
#   }
#   private_routes = {
#     enabled                = true
#     root_domain            = "revenge-games.staging"
#     load_balancer_listener = data.terraform_remote_state.staging.outputs.aws_lb_listener_4
#   }
#   alb_dns_name = data.terraform_remote_state.staging.outputs.alb_private_dns_4


#   services = local.lambda_logic_4
# }



# module "dev_lambda_services_4" {
#   source  = "../../../modules/lambda-service-logic-4"
#   app_env = "dev"
#   providers = {
#     aws = aws.ap_southeast_1
#   }
#   network_configuration = {
#     vpc_id = data.terraform_remote_state.dev.outputs.network_info.vpc.id
#     subnets = [
#       data.terraform_remote_state.dev.outputs.network_info.subnet_private_1.id,
#       data.terraform_remote_state.dev.outputs.network_info.subnet_private_2.id
#     ]
#     security_groups = [
#       data.terraform_remote_state.dev.outputs.network_info.vpc.default_security_group_id
#     ]
#   }
#   private_routes = {
#     enabled                = true
#     root_domain            = "revenge-games.dev"
#     load_balancer_listener = data.terraform_remote_state.dev.outputs.aws_lb_listener_4
#   }
#   alb_dns_name = data.terraform_remote_state.dev.outputs.alb_private_dns_4


#   services = local.lambda_logic_4
# }

# module "prod_lambda_services_4" {
#   source  = "../../../modules/lambda-service-logic-4"
#   app_env = "prod"
#   providers = {
#     aws = aws.sa_east_1
#   }
#   network_configuration = {
#     vpc_id = data.terraform_remote_state.prod.outputs.network_info.vpc.id
#     subnets = [
#       data.terraform_remote_state.prod.outputs.network_info.subnet_private_1.id,
#       data.terraform_remote_state.prod.outputs.network_info.subnet_private_2.id
#     ]
#     security_groups = [
#       data.terraform_remote_state.prod.outputs.network_info.vpc.default_security_group_id
#     ]
#   }
#   private_routes = {
#     enabled                = true
#     root_domain            = "revenge-games.prod"
#     load_balancer_listener = data.terraform_remote_state.prod.outputs.aws_lb_listener_4
#   }
#   alb_dns_name = data.terraform_remote_state.prod.outputs.alb_private_dns_4


#   services = local.lambda_logic_4
# }
