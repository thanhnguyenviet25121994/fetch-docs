resource "aws_sns_topic" "this" {
  name = var.sns_topic_name

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role" "this" {
  name = "${var.environment}-lambda-alert-to-lark-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs_restart_policy" {
  name        = "${var.environment}-ecs-restart-policy"
  description = "Policy to allow Lambda to restart ECS services"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:UpdateService",
        "ecs:DescribeServices"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ecs_restart_policy_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ecs_restart_policy.arn
}

resource "aws_lambda_function" "lark_bot" {
  filename         = "${path.module}/../../modules/lambda-alert-to-lark/lambda-alert-to-lark.zip"
  function_name    = "${var.environment}-lambda-alert-to-lark"
  role             = aws_iam_role.this.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("${path.module}/../../modules/lambda-alert-to-lark/lambda-alert-to-lark.zip")
  runtime          = "nodejs20.x"

  environment {
    variables = {
      LARK_WEBHOOK_URL = "${var.LARK_WEBHOOK_URL}"
    }
  }

  lifecycle {
    ignore_changes = [
      # List the attributes you want to ignore changes for
      source_code_hash
    ]
  }
}

resource "aws_lambda_permission" "sns_to_lark" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lark_bot.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.this.arn
}

resource "aws_sns_topic_subscription" "lark_subscription" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lark_bot.arn
}