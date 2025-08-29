# data "template_file" "inline" {
#   template = templatefile(local.policy_file, {
#     # key = value
#   })
#   #   vars = {
#   #     resources = jsonencode(var.resources)
#   #   }
# }

module "ecs_service_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "v5.33.0"

  role_name             = "${local.environment}-${local.project_name}-ecs-service"
  role_description      = "Roles for ${local.environment} ecs-service}"
  create_role           = true
  role_requires_mfa     = false
  trusted_role_services = ["ec2.amazonaws.com"]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",
  ]
}

module "ecs_task_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "v5.33.0"

  role_name             = "${local.environment}-${local.project_name}-ecs-task-role"
  role_description      = "Roles for ${local.environment} ecs-task-role}"
  create_role           = true
  role_requires_mfa     = false
  trusted_role_services = ["ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
}

resource "aws_iam_role_policy" "inline" {
  name = "${local.environment}-${local.project_name}-ecs-task-role"
  role = module.ecs_task_role.iam_role_name
  # policy = data.template_file.inline.rendered
  policy = templatefile(local.policy_file, {})
}



data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::pg-dev-proof-of-tranfser",
    ]
  }
}