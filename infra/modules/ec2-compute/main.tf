

module "ec2_instances" {
  for_each = var.instances
  source   = "terraform-aws-modules/ec2-instance/aws"
  version  = "v4.5.0"

  name                        = "${var.app_env}-${each.key}"
  ami                         = var.ami
  instance_type               = each.value.instance_type
  subnet_id                   = var.network_configuration.subnets
  associate_public_ip_address = true

  vpc_security_group_ids = var.network_configuration.security_groups

  create_iam_instance_profile = true
  iam_role_name               = "ir.${var.app_env}-${each.value.name}-ec2"
  iam_role_description        = "IAM role for EC2 instance"
  user_data_replace_on_change = false
  iam_role_use_name_prefix    = false
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  }

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = each.value.volume_size
    },
  ]

  user_data = var.user_data

  tags = var.tags

}

resource "aws_eip" "this" {
  for_each          = var.instances
  vpc               = true
  network_interface = module.ec2_instances[each.key].primary_network_interface_id

  depends_on = [
    module.ec2_instances
  ]
}


# resource "time_sleep" "wait_for_ec2_instances" {
#   for_each        = var.instances
#   create_duration = "180s"

#   triggers = {
#     primary_network_interface_ids = module.ec2_instances[each.key].primary_network_interface_id
#   }

#   depends_on = [module.ec2_instances]
# }