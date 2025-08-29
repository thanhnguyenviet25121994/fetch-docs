module "iam_invoke_lambda" {
  source = "../../../modules/iam-user"

  name = "invoke_lambda"

  create_iam_user_login_profile = true
  create_iam_access_key         = false
  policy_arns = [
    aws_iam_policy.invoke_lambda.arn,
    aws_iam_policy.iam_self_management.arn
  ]
}
module "iam_manhchu" {
  source = "../../../modules/iam-user"

  name = "manh.chu@revenge.games"

  create_iam_user_login_profile = true
  create_iam_access_key         = false
  policy_arns = [
    "arn:aws:iam::aws:policy/IAMUserChangePassword",
    "arn:aws:iam::211125478834:policy/ip.Developer",
    aws_iam_policy.portal_operator_policy.arn
  ]
}
module "iam_datpham" {
  source = "../../../modules/iam-user"

  name = "dat.pham@revenge.games"

  create_iam_user_login_profile = true
  create_iam_access_key         = false
  policy_arns = [
    "arn:aws:iam::aws:policy/IAMUserChangePassword",
    "arn:aws:iam::211125478834:policy/ip.Developer"
  ]
}
module "iam_hungtruong" {
  source = "../../../modules/iam-user"

  name = "hung.truong@revenge.games"

  create_iam_user_login_profile = true
  create_iam_access_key         = false
  policy_arns = [
    "arn:aws:iam::aws:policy/IAMUserChangePassword",
    "arn:aws:iam::211125478834:policy/ip.Developer",
    aws_iam_policy.portal_operator_policy.arn
  ]
}


# module "iam_thao" {
#   source = "../../../modules/iam-user"

#   name = "thao.tran@revenge.games"

#   create_iam_user_login_profile = true
#   create_iam_access_key         = false
#   policy_arns = [
#     "arn:aws:iam::aws:policy/IAMUserChangePassword",
#     "arn:aws:iam::211125478834:policy/ip.Developer"
#   ]
# }

module "iam_phuoc" {
  source = "../../../modules/iam-user"

  name = "phuoc.le@revenge.games"

  create_iam_user_login_profile = true
  create_iam_access_key         = false
  policy_arns = [
    "arn:aws:iam::aws:policy/IAMUserChangePassword",
    "arn:aws:iam::211125478834:policy/ip.Developer"
  ]
}

module "iam_afun" {
  source = "../../../modules/iam-user"

  name = "afun"

  create_iam_user_login_profile = false
  create_iam_access_key         = true
  policy_arns = [
    "arn:aws:iam::211125478834:policy/ip.SSMAfun"
  ]
}