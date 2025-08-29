module "lambda_python_zip_deployment_notification" {
  source = "./lambda-python-zip"
  #lambda-python-zip
  lambda_function_code_path = var.lambda_function_code_path
  lambda_python_zip_name    = "lambda_batch_24h"
}


module "lambda_to_telegram_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "v5.33.0"

  role_name               = "${var.app_env}-lambda-${var.app_name}"
  role_description        = "Roles for ${var.app_env} batch 24h"
  create_role             = true
  create_instance_profile = true
  role_requires_mfa       = false
  trusted_role_services   = ["lambda.amazonaws.com"]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::211125478834:policy/ip.AllowReadOnlyBatch"
  ]

}

module "lambda_batch_24h" {
  source = "./lambda"
  #basic
  env    = var.app_env
  region = var.aws_region

  #lambda
  lambda_function_name     = "lambda-batch-24h"
  lambda_function_filename = module.lambda_python_zip_deployment_notification.lambda_python_zip_source
  lambda_function_handler  = module.lambda_python_zip_deployment_notification.lambda_python_zip_name
  lambda_function_role     = module.lambda_to_telegram_role.iam_role_arn
  lambda_function_timeout  = 180

  lambda_function_environment = {
    LARK_WEBHOOK_URL = "https://open.larksuite.com/open-apis/bot/v2/hook/868b1d58-2e50-4460-8e80-05d585b7af96"
  }
}

module "eventbridge_trigger_lambda" {
  source = "./eventbridge"

  name                         = "lambda-batch-24h"
  lambda_name                  = module.lambda_batch_24h.lambda_function_name
  schedule_expression          = "cron(0 */6 * * ? *)"
  lambda_function_arn          = module.lambda_batch_24h.lambda_function_arn
  schedule_expression_timezone = "Asia/Ho_Chi_Minh"

  target_input = "{\"key2\":\"value2\"}"

}