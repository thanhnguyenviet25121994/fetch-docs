module "ec2" {
  source = "../../modules/ec2-compute"

  ami = "ami-047b32292da23477b"

  instances = {
    testing-01 = {
      name          = "rtp-testing-01"
      instance_type = "t4g.2xlarge"
      volume_size   = 100
    }
    testing-02 = {
      name          = "rtp-testing-02"
      instance_type = "t4g.2xlarge"
      volume_size   = 100
    }
    testing-03 = {
      name          = "rtp-testing-03"
      instance_type = "t4g.2xlarge"
      volume_size   = 100
    }
    testing-04 = {
      name          = "rtp-testing-04"
      instance_type = "t4g.2xlarge"
      volume_size   = 100
    }
    testing-05 = {
      name          = "rtp-testing-05"
      instance_type = "t4g.2xlarge"
      volume_size   = 100
    }
    runner-autotest = {
      name          = "runner-autotest"
      instance_type = "c6g.xlarge"
      volume_size   = 100
    }

  }
  app_env = local.environment
  network_configuration = {
    subnets = "${module.dev_networking.subnet_public_1.id}"
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]

  }

  user_data = base64encode(templatefile(
    "./template/ubuntu.tpl",
    {
      "ssh_user"     = "ubuntu"
      "user"         = "ubuntu"
      "project_name" = local.project
      "hostname"     = "${local.project}-${local.environment}-testing"
      "prompt_color" = "32m"
    }
  ))

  tags = {
    Project_Name = "${local.project}"
    Environment  = "${local.environment}"
    Terraform    = true
  }

}


module "ec2_runner" {
  source = "../../modules/ec2-compute"

  ami = "ami-00c055f797c1cc760"

  instances = {
    runner-01 = {
      name          = "github-runner-01"
      instance_type = "c6g.xlarge"
      volume_size   = 100
    }
    thuan-01 = {
      name          = "thuan-01"
      instance_type = "c6g.xlarge"
      volume_size   = 100
    }

  }
  app_env = local.environment
  network_configuration = {
    subnets = "${module.dev_networking.subnet_public_1.id}"
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]

  }

  user_data = base64encode(templatefile(
    "./template/ubuntu.tpl",
    {
      "ssh_user"     = "ubuntu"
      "user"         = "ubuntu"
      "project_name" = local.project
      "hostname"     = "${local.project}-${local.environment}-testing"
      "prompt_color" = "32m"
    }
  ))

  tags = {
    Project_Name = "${local.project}"
    Environment  = "${local.environment}"
    Terraform    = true
  }

}


module "ec2_rtp" {
  source = "../../modules/ec2-compute"

  ami = "ami-05c0c6dec1211bbe0"

  instances = {
    rtp-01 = {
      name          = "rtp-01"
      instance_type = "c6g.4xlarge"
      volume_size   = 100
    }


  }
  app_env = local.environment
  network_configuration = {
    subnets = "${module.dev_networking.subnet_public_1.id}"
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]

  }

  user_data = base64encode(templatefile(
    "./template/ubuntu.tpl",
    {
      "ssh_user"     = "ubuntu"
      "user"         = "ubuntu"
      "project_name" = local.project
      "hostname"     = "${local.project}-${local.environment}-testing"
      "prompt_color" = "32m"
    }
  ))

  tags = {
    Project_Name = "${local.project}"
    Environment  = "${local.environment}"
    Terraform    = true
  }

}