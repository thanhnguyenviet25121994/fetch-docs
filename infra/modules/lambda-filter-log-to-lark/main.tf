module "lambda_python_zip_notification" {
  source = "./lambda-python-zip"
  #lambda-python-zip
  lambda_function_code_path = var.lambda_function_code_path
  lambda_python_zip_name    = "filter_log_to_lark"
}


module "lambda_to_telegram_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "v5.33.0"

  role_name               = "prod-lambda-transfer-wallet-log-to-lark"
  role_description        = "Roles for ${var.app_env} lambda_to_telegram"
  create_role             = true
  create_instance_profile = true
  role_requires_mfa       = false
  trusted_role_services   = ["lambda.amazonaws.com"]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ]

}

module "filter_log_to_lark_notification" {
  source = "./lambda"
  #basic
  env    = var.app_env
  region = var.aws_region

  #lambda
  lambda_function_name     = var.app_name
  lambda_function_filename = module.lambda_python_zip_notification.lambda_python_zip_source
  lambda_function_handler  = module.lambda_python_zip_notification.lambda_python_zip_name
  lambda_function_role     = module.lambda_to_telegram_role.iam_role_arn
  lambda_function_timeout  = 180

  lambda_function_environment = var.lambda_env
}
