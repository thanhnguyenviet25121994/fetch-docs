module "lambda_python_zip_deployment_notification" {
  source = "./lambda-python-zip"
  #lambda-python-zip
  lambda_function_code_path = var.lambda_function_code_path
  lambda_python_zip_name    = "ecs_deployment_notification"
}


module "lambda_to_telegram_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "v5.33.0"

  role_name               = "${var.app_env}-lambda_to_telegram"
  role_description        = "Roles for ${var.app_env} lambda_to_telegram"
  create_role             = true
  create_instance_profile = true
  role_requires_mfa       = false
  trusted_role_services   = ["lambda.amazonaws.com"]
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

}

module "lambda_ecs_deployment_notification" {
  source = "./lambda"
  #basic
  env    = var.app_env
  region = var.aws_region

  #lambda
  lambda_function_name     = "ecs-deployment-notification"
  lambda_function_filename = module.lambda_python_zip_deployment_notification.lambda_python_zip_source
  lambda_function_handler  = module.lambda_python_zip_deployment_notification.lambda_python_zip_name
  lambda_function_role     = module.lambda_to_telegram_role.iam_role_arn
  lambda_function_timeout  = 180

  lambda_function_environment = {
    WEBHOOK_URL = "https://open.larksuite.com/open-apis/bot/v2/hook/45d50baf-048b-4f90-8f79-14caa5dd4b3a"
    # CHATOPS_URL = "https://open.larksuite.com/open-apis/bot/v2/hook/c79dd154-2a34-4a6d-b6e5-731fbc0e804d"
  }
}

module "eventbridge_lambda_ecs_deployment_notification" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "v3.10.0"

  # bus_name = "${var.app_env}-${var.project_name}-ecs-deployment-notification"
  create_bus = false
  role_name  = "${var.app_env}-eb"


  rules = {
    "${var.app_env}-ecs-deployment-notification" = {
      description = "Capture all ecs deployment data"
      event_pattern = jsonencode({
        "source" : ["aws.ecs"],
        "detail-type" : ["ECS Deployment State Change"],
        "detail" : {
          "clusterArn" : "${var.ecs_cluster_arn}"
        }
      })
      # enabled       = true
    }
  }

  targets = {
    "${var.app_env}-ecs-deployment-notification" = [
      {
        name = "lambda_ecs_deployment_notification"
        arn  = module.lambda_ecs_deployment_notification.lambda_function_arn
      }
    ]
  }
}


resource "aws_lambda_permission" "allow_eventbridge_lambda_ecs_deployment_notification" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_ecs_deployment_notification.lambda_function_arn
  principal     = "events.amazonaws.com"

  # Use the EventBridge rule's ARN
  source_arn = module.eventbridge_lambda_ecs_deployment_notification.eventbridge_rule_arns["${var.app_env}-ecs-deployment-notification"]
}