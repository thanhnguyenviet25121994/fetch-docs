data "aws_caller_identity" "current" {
  count = local.aws_account_id == "" ? 1 : 0
}

data "aws_partition" "current" {}

locals {
  partition = data.aws_partition.current.partition
}

# Allows MFA-authenticated IAM users to manage their own credentials on the My security credentials page
# https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage.html
data "aws_iam_policy_document" "iam_self_management" {
  statement {
    sid = "AllowViewAccountInfo"

    effect = "Allow"

    actions = [
      "iam:GetAccountSummary",
      "iam:GetAccountPasswordPolicy",
      "iam:ListAccountAliases",
      "iam:ListVirtualMFADevices"
    ]

    resources = ["*"]
  }

  statement {
    sid = "AllowManageOwnPasswords"

    effect = "Allow"

    actions = [
      "iam:ChangePassword",
      "iam:GetLoginProfile",
      "iam:GetUser",
      "iam:UpdateLoginProfile"
    ]

    resources = [
      "arn:${local.partition}:iam::${local.aws_account_id}:user/$${aws:username}",
      "arn:${local.partition}:iam::${local.aws_account_id}:user/*/$${aws:username}"
    ]
  }

  statement {
    sid = "AllowManageOwnAccessKeys"

    effect = "Allow"

    actions = [
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
      "iam:GetAccessKeyLastUsed",
      "iam:TagUser",
      "iam:ListUserTags",
      "iam:UntagUser",
    ]

    resources = [
      "arn:${local.partition}:iam::${local.aws_account_id}:user/$${aws:username}",
      "arn:${local.partition}:iam::${local.aws_account_id}:user/*/$${aws:username}"
    ]
  }

}