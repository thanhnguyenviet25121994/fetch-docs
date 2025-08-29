module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v5.1.0"

  name                   = "${local.environment}-bastion-sg"
  description            = "Allow access to ${local.environment} bastion "
  use_name_prefix        = false
  revoke_rules_on_delete = false

  vpc_id = module.prod_asia_networking.vpc.id

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
      cidr_blocks = "10.40.0.0/16"
    }
  ]

}

module "ec2_bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "v5.6.0"

  name = lower("${local.environment}-bastion")

  ami                         = "ami-03fa85deedfcac80b"
  instance_type               = "t3a.small"
  subnet_id                   = module.prod_asia_networking.subnet_private_1.id
  vpc_security_group_ids      = [module.bastion_sg.security_group_id]
  associate_public_ip_address = false
  create_iam_instance_profile = true
  iam_role_name               = lower("ir.${local.environment}-bastion")
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



################
## RDS - SG
module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v5.1.0"

  name                   = "${local.environment}-rds-sg"
  description            = "Allow access to ${local.environment} rds "
  use_name_prefix        = false
  revoke_rules_on_delete = false

  vpc_id = module.prod_asia_networking.vpc.id

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
      cidr_blocks = "10.40.0.0/16"
    }
  ]

}


###########
### VPN SG
module "vpn_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v5.1.0"

  name                   = "${local.environment}-vpn-sg"
  description            = "Allow access to ${local.environment} vpn "
  use_name_prefix        = false
  revoke_rules_on_delete = false

  vpc_id = "vpc-03d1c7052fa6d31ff" # default vpn

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
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 1194
      to_port     = 1194
      protocol    = "tcp"
      description = "openvpn"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 1194
      to_port     = 1194
      protocol    = "udp"
      description = "openvpn"
      cidr_blocks = "0.0.0.0/0"
    },

  ]

}


module "vpn" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "v5.6.0"

  name = lower("${local.environment}-vpn")

  ami                         = "ami-0b1e6d46c5f3bf788"
  instance_type               = "t3a.medium"
  subnet_id                   = "subnet-03487f9b4b09a3038" ## default public subnet
  vpc_security_group_ids      = [module.vpn_sg.security_group_id]
  associate_public_ip_address = true
  create_iam_instance_profile = true
  iam_role_name               = lower("ir.${local.environment}-vpn")
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


resource "aws_eip" "vpn" {
  vpc      = true
  instance = module.vpn.id

  depends_on = [
    module.vpn
  ]
  tags = {
    "Name" = "${local.project}-${local.environment}-vpn"
  }
}




###### n8n host
module "n8n_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v5.1.0"

  name                   = "${local.environment}-n8n-sg"
  description            = "Allow access to ${local.environment} n8n "
  use_name_prefix        = false
  revoke_rules_on_delete = false

  vpc_id = module.prod_asia_networking.vpc.id

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
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },


  ]

}


module "n8n" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "v5.6.0"

  name = lower("${local.environment}-n8n")

  ami                         = "ami-06f87694403c8ae6a"
  instance_type               = "t4g.medium"
  subnet_id                   = module.prod_asia_networking.subnet_public_1.id
  vpc_security_group_ids      = [module.n8n_sg.security_group_id]
  associate_public_ip_address = true
  create_iam_instance_profile = true
  iam_role_name               = lower("ir.${local.environment}-n8n")
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
    sudo apt install docker.io docker-compose -y
  EOT

}


resource "aws_eip" "n8n" {
  vpc      = true
  instance = module.n8n.id

  depends_on = [
    module.n8n
  ]
  tags = {
    "Name" = "${local.project}-${local.environment}-n8n"
  }
}