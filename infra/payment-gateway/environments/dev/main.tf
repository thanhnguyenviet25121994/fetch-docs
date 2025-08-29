

module "aws-data" {
  source = "../../modules/aws-data"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v4.0.2"
  name    = lower("${local.environment}-${local.project_name}")
  cidr    = local.vpc_cidr
  azs     = [for v in module.aws-data.available_aws_availability_zones_names : v]

  private_subnets = [
    for zone_id in module.aws-data.available_aws_availability_zones_zone_ids :
    cidrsubnet(local.vpc_cidr, local.cidr_newbits, tonumber(substr(zone_id, length(zone_id) - 1, 1)))
  ]
  public_subnets = [
    for zone_id in module.aws-data.available_aws_availability_zones_zone_ids :
    cidrsubnet(local.vpc_cidr, local.cidr_newbits, tonumber(substr(zone_id, length(zone_id) - 1, 1)) + 20)
  ]
  database_subnets = !local.create_database_subnet_group ? [] : [
    for zone_id in module.aws-data.available_aws_availability_zones_zone_ids :
    cidrsubnet(local.vpc_cidr, local.cidr_newbits, tonumber(substr(zone_id, length(zone_id) - 1, 1)) + 30)
  ]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_vpn_gateway   = false
  enable_dhcp_options  = false

  create_database_subnet_group = local.create_database_subnet_group

}


module "ec2_bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "v5.6.0"

  name = lower("${local.environment}-${local.project_name}-bastion")

  ami                         = "ami-03fa85deedfcac80b"
  instance_type               = "t3a.small"
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [module.bastion_sg.security_group_id]
  associate_public_ip_address = false
  create_iam_instance_profile = true
  iam_role_name               = lower("ir.${local.environment}-${local.project_name}-bastion")
  iam_role_description        = "IAM role for EC2 instance"
  user_data_replace_on_change = false
  iam_role_use_name_prefix    = false
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  }
  root_block_device = [
    {
      delete_on_termination = false
      volume_size           = 80
      volume_type           = "gp3"
    }
  ]

  metadata_options = {
    http_tokens = "required"
  }

  user_data = <<-EOT
    #!/bin/bash
    sudo apt update -y
    sudo apt install docker.io -y
  EOT

}



##############
### ECR
##############

module "ecrs" {
  source  = "cloudposse/ecr/aws"
  version = "0.38.0"

  namespace = local.project_name
  stage     = local.environment
  name      = "app"

  image_names          = [for item in local.ecr_repos : "${item}"]
  image_tag_mutability = "MUTABLE"
  max_image_count      = 50
  scan_images_on_push  = false

}

############
## ECS cluster
############
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "v5.7.4"

  cluster_name = "${local.environment}-${local.project_name}-service"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/${local.environment}-${local.project_name}-service"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
        base   = 20
      }
    }
    # FARGATE_SPOT = {
    #   default_capacity_provider_strategy = {
    #     weight = 50
    #   }
    # }
  }
}
