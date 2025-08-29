################################
# Lambda Function
################################

resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_function_name}-role-${var.aws_region}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# CloudWatch Logs policy
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# S3 access policy
resource "aws_iam_policy" "s3_logs_access" {
  name        = "${var.lambda_function_name}-s3-access-${var.aws_region}"
  description = "Policy for accessing S3 ALB logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.log_bucket_name}",
          "arn:aws:s3:::${var.log_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_logs_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_logs_access.arn
}

data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/package"
  output_path = "${path.module}/spin-monitor.zip"
}

resource "aws_lambda_function" "alb_log_analyzer" {
  function_name    = var.lambda_function_name
  filename         = data.archive_file.lambda_package.output_path
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  handler          = "analyze-alb-logs-lambda.lambda_handler"
  runtime          = "python3.10"
  timeout          = 900
  memory_size      = 512

  # dynamic "environment" {
  #   for_each = each.value.env != [] ? [each.value.env] : []
  #   content {
  #     variables = each.value.env
  #   }
  # }

  tags = {
    Environment = var.app_env
  }
}

################################
# CloudWatch Event Rule - Scheduler
################################

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.lambda_function_name}-schedule"
  description         = "Schedule for ALB Log Analyzer Lambda function"
  schedule_expression = "cron(15 0,6,12,18 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "InvokeLambda"
  arn       = aws_lambda_function.alb_log_analyzer.arn

  # Pass parameters as JSON input
  input = jsonencode({
    LOG_BUCKET_NAME  = var.log_bucket_name
    LOG_PREFIX       = var.log_prefix
    AWS_REGION       = var.aws_region
    SEND_TO_LARK     = var.send_to_lark
    HOURS_TO_ANALYZE = var.hours_to_analyze
  })
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alb_log_analyzer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}

