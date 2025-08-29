module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v5.1.0"

  name                   = lower("${local.project_name}-${local.environment}-rds")
  description            = "Allow access to ${local.environment} ${lower("${local.project_name}")} rds"
  use_name_prefix        = false
  revoke_rules_on_delete = false

  vpc_id = module.vpc.vpc_id

  ## Outbound:
  egress_rules            = ["all-all"]
  egress_cidr_blocks      = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks = ["::/0"]

  ## Inbound:
  ingress_with_self = [
    {
      from_port   = "-1"
      to_port     = "-1"
      protocol    = "-1"
      description = "Itself"
    }
  ]
  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      cidr_blocks = module.vpc.private_subnets_cidr_blocks[0]
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = module.vpc.private_subnets_cidr_blocks[1]
    },
    {
      rule        = "postgresql-tcp"
      cidr_blocks = module.vpc.private_subnets_cidr_blocks[2]
    }
  ]

}


module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v5.1.0"

  name                   = "${local.project_name}-${local.environment}-bastion"
  description            = "Allow access to ${local.environment} bastion "
  use_name_prefix        = false
  revoke_rules_on_delete = false

  vpc_id = module.vpc.vpc_id

  ## Outbound:
  egress_rules            = ["all-all"]
  egress_cidr_blocks      = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks = ["::/0"]

  ## Inbound:
  ingress_with_self = [
    {
      from_port   = "-1"
      to_port     = "-1"
      protocol    = "-1"
      description = "Itself"
    }
  ]
  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "10.10.0.0/16"
    }
  ]

}



module "elb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v5.1.0"

  name                   = "${local.project_name}-${local.environment}-sg-alb"
  description            = "Allow access to ${local.project_name} ${local.environment} alb"
  use_name_prefix        = false
  revoke_rules_on_delete = false

  vpc_id = module.vpc.vpc_id

  ## Outbound:
  egress_rules            = ["all-all"]
  egress_cidr_blocks      = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks = ["::/0"]

  ## Inbound:
  ingress_with_self = [
    {
      from_port   = "-1"
      to_port     = "-1"
      protocol    = "-1"
      description = "Itself"
    }
  ]

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

}

module "service_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v5.1.0"

  name                   = "${local.project_name}-${local.environment}-sg-services"
  use_name_prefix        = false
  revoke_rules_on_delete = false

  vpc_id = module.vpc.vpc_id

  ## Outbound:
  egress_rules            = ["all-all"]
  egress_cidr_blocks      = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks = ["::/0"]

  ## Inbound:
  ingress_with_self = [
    {
      from_port   = "-1"
      to_port     = "-1"
      protocol    = "-1"
      description = "Itself"
    }
  ]

  ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      description              = "allow access from ALB"
      source_security_group_id = module.elb_sg.security_group_id
    }
  ]

}