module "iam_hungvu" {
  source = "../../../modules/iam-user"

  name = "hung.vu@${local.domain}"

  create_iam_user_login_profile = true
  create_iam_access_key         = false
}
module "iam_thanh" {
  source = "../../../modules/iam-user"

  name = "thanh.nguyenv@${local.domain}"

  create_iam_user_login_profile = true
  create_iam_access_key         = false
}

module "iam_group_devops" {
  source = "../../../modules/iam-groups"

  name = "DevOps"

  create_group = true

  custom_group_policy_arns = [
    data.aws_iam_policy.admin.arn
  ]
  group_users = [
    module.iam_hungvu.iam_user_name,
    module.iam_thanh.iam_user_name
  ]

}