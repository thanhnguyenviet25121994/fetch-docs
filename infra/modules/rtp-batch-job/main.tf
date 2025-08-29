##
## AWS Batch job for Lottery Ticket
##

####################################
## Local variables
####################################

locals {
  # version    = var.batch_configs.version
  name    = "${var.prefix}-${var.app_name}"
  type    = try(var.batch_configs.type, "FARGATE")
  fargate = contains(["FARGATE", "FARGATE_SPOT"], local.type)

  subnet_id = ["${var.subnet_id}"]

  tags = {
    env = var.prefix
  }
}

####################################
## AWS Batch
####################################

## SG
resource "aws_security_group" "this" {
  count = var.created ? 1 : 0

  name        = local.name
  description = "sg for ${local.name}"
  vpc_id      = var.vpc_id
  tags        = local.tags

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Computing
resource "aws_batch_compute_environment" "this" {
  count = var.created ? 1 : 0

  compute_environment_name = local.name
  service_role             = try(aws_iam_role.service[0].arn, "")
  type                     = try(var.batch_configs.compute_env_type, "MANAGED")
  tags                     = local.tags

  compute_resources {
    type                = local.type
    allocation_strategy = local.fargate ? null : try(var.batch_configs.allocation_strategy, null)
    bid_percentage      = local.fargate ? null : try(var.batch_configs.bid_percentage, null)
    min_vcpus           = local.fargate ? null : try(var.batch_configs.min_vcpus, null)
    max_vcpus           = try(var.batch_configs.max_vcpus, 4)
    desired_vcpus       = local.fargate ? null : try(var.batch_configs.desired_vcpus, null)
    instance_type       = local.fargate ? [] : try(var.batch_configs.instance_types, [])
    ec2_key_pair        = local.fargate ? null : try(var.batch_configs.ec2_key_pair, null)
    instance_role       = local.fargate ? null : try(aws_iam_instance_profile.instance[0].arn, null)
    spot_iam_fleet_role = local.type == "SPOT" ? try(aws_iam_role.spot_fleet[0].arn, null) : null
    security_group_ids  = [try(aws_security_group.this[0].id, "")]
    subnets             = local.subnet_id
    tags                = local.fargate ? null : local.tags

    dynamic "ec2_configuration" {
      for_each = !local.fargate && try(var.batch_configs.ec2_configuration, null) != null ? [var.batch_configs.ec2_configuration] : []
      content {
        image_id_override = lookup(ec2_configuration.value, "image_id_override", null)
        image_type        = lookup(ec2_configuration.value, "image_type", null)
      }
    }

    dynamic "launch_template" {
      for_each = !local.fargate && try(var.batch_configs.launch_template, null) != null ? [var.batch_configs.launch_template] : []
      content {
        launch_template_id   = lookup(launch_template.value, "id", null)
        launch_template_name = lookup(launch_template.value, "name", null)
        version              = lookup(launch_template.value, "version", null)
      }
    }
  }

  depends_on = [aws_iam_role_policy_attachment.service]
}

## Job Queue
resource "aws_batch_job_queue" "this" {
  count = var.created && var.create_service_iam_role ? 1 : 0

  name                 = local.name
  state                = "ENABLED"
  priority             = 1
  compute_environments = [aws_batch_compute_environment.this[0].arn]
  tags                 = local.tags
}

## Job Definition
locals {
  batch_vcpu     = try(var.batch_configs.vcpu, ".25")
  batch_memory   = try(var.batch_configs.memory, "512")
  image          = var.batch_configs.image
  log_group      = local.name
  execution_role = try(aws_iam_role.task_exec[0].arn, "")
  job_role       = try(aws_iam_role.jobrole[0].arn, "")
}

resource "aws_batch_job_definition" "this" {
  count = var.created ? 1 : 0

  name                  = local.name
  platform_capabilities = try(var.batch_configs.platform_capabilities, ["FARGATE"])
  parameters            = {}
  type                  = "container"
  tags                  = local.tags
  container_properties = local.fargate ? templatefile(
    "${path.module}/container_properties.json",
    {
      image            = local.image
      vcpu             = local.batch_vcpu
      memory           = local.batch_memory
      log_group_name   = local.log_group
      log_group_region = var.main_region
      execution_role   = local.execution_role
      job_role         = local.job_role
    }
    ) : templatefile(
    "${path.module}/container_properties_ec2.json",
    {
      image            = local.image
      log_group_name   = local.log_group
      log_group_region = var.main_region
      execution_role   = local.execution_role

    }
  )

  timeout {
    attempt_duration_seconds = try(var.batch_configs.timeout_attempt_duration_seconds, 3600)
  }
}
