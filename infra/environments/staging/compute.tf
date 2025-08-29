module "ec2" {
  source = "../../modules/ec2-compute"

  ami = "ami-064c9bc9afb8dc699"

  instances = {
    runner-autotest = {
      name          = "runner-autotest"
      instance_type = "c6g.xlarge"
      volume_size   = 100
    },
    thuan-ec2 = {
      name          = "thuan-ec2"
      instance_type = "c6g.xlarge"
      volume_size   = 100
    }

  }
  app_env = local.environment
  network_configuration = {
    subnets = "${module.staging_networking.subnet_public_1.id}"
    security_groups = [
      module.staging_networking.vpc.default_security_group_id
    ]

  }

  user_data = base64encode(templatefile(
    "./template/ubuntu.tpl",
    {
      "ssh_user"     = "ubuntu"
      "user"         = "ubuntu"
      "project_name" = local.project
      "hostname"     = "${local.project}-${local.environment}-runner"
      "prompt_color" = "32m"
    }
  ))

  tags = {
    Project_Name = "${local.project}"
    Environment  = "${local.environment}"
    Terraform    = true
  }

}


module "ec2_sentry" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "v5.6.0"

  name = lower("${local.environment}-sentry")

  ami                         = "ami-0cef62348b8426830"
  instance_type               = "m6g.2xlarge"
  subnet_id                   = module.staging_networking.subnet_public_1.id
  vpc_security_group_ids      = [module.staging_networking.vpc.default_security_group_id]
  associate_public_ip_address = true
  create_iam_instance_profile = true
  iam_role_name               = lower("ir.${local.environment}-sentry")
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

resource "aws_eip" "sentry" {
  vpc      = true
  instance = module.ec2_sentry.id

  depends_on = [
    module.ec2_sentry
  ]
  tags = {
    "Name" = "${local.project}-${local.environment}-sentry"
  }
}