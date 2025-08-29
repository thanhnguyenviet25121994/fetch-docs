module "vpn_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v5.1.0"

  name                   = "${local.project}-${local.environment}-vpn-ec2"
  description            = "Allow access to ${local.environment} vpn ec2"
  use_name_prefix        = false
  revoke_rules_on_delete = false

  vpc_id = "vpc-026e2e0a090cfb667"

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
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 1194
      to_port     = 1194
      protocol    = "udp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
    }


  ]

}
module "vpn" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "v5.6.0"

  name = "${local.project}-${local.environment}-vpn"

  ami           = "ami-0d1ff6e866ea68fe7"
  instance_type = "t3a.small"
  # key_name                    = module.ssh_key_file.keypair_name
  subnet_id                   = "subnet-0c172954f05163b49"
  vpc_security_group_ids      = [module.vpn_sg.security_group_id]
  associate_public_ip_address = true

  create_iam_instance_profile = true
  iam_role_name               = "ir.${local.environment}-vpn"
  iam_role_description        = "IAM role for EC2 instance"
  user_data_replace_on_change = false
  iam_role_use_name_prefix    = false
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  }

  root_block_device = [
    {
      delete_on_termination = false
      volume_size           = 100
      volume_type           = "gp3"
    }
  ]

  metadata_options = {
    http_tokens = "required"
  }

  #   user_data = local.user_data

  depends_on = [module.vpn_sg]
}

## EIP:
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