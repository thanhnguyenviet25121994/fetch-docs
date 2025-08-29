provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "lark_bot" {
  filename         = "${path.module}/../../modules/lambda-to-lark/lambda-to-lark.zip"
  function_name    = "${var.environment}-lambda-to-lark-bot"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("${path.module}/../../modules/lambda-to-lark/lambda-to-lark.zip")
  runtime          = "nodejs20.x"

  environment {
    variables = {
      LARK_WEBHOOK_URL = "${var.lark_webhook_url}"
    }
  }
}

resource "aws_cloudwatch_log_subscription_filter" "this" {
  name            = "${var.environment}-error-subscription"
  log_group_name  = var.log_group_name
  filter_pattern  = var.filter_pattern
  destination_arn = aws_lambda_function.lark_bot.arn

  depends_on = [aws_lambda_permission.allow_cloudwatch]
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.environment}_lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lark_bot.function_name
  principal     = "logs.${var.region}.amazonaws.com"
  source_arn    = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${var.log_group_name}:*"
}