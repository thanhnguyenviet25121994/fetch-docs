resource "aws_lambda_function" "lambda_function" {
  function_name    = "${var.env}-${var.lambda_function_name}"
  description      = "schedule event bridge to Lambda"
  filename         = var.lambda_function_filename
  source_code_hash = filebase64sha256(var.lambda_function_filename)
  handler          = "${var.lambda_function_handler}.lambda_handler"
  role             = var.lambda_function_role

  runtime                        = var.lambda_runtime
  timeout                        = var.lambda_function_timeout
  memory_size                    = 128
  reserved_concurrent_executions = var.lambda_function_reserved_concurrent_executions

  dynamic "environment" {
    for_each = var.lambda_function_environment != [] ? [var.lambda_function_environment] : []
    content {
      variables = var.lambda_function_environment
    }
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = {
    Name        = "${var.env}-${var.lambda_function_name}"
    Environment = var.env
  }
}

resource "aws_lambda_function_event_invoke_config" "lambda_function_event_invoke_config" {
  function_name                = aws_lambda_function.lambda_function.function_name
  qualifier                    = "$LATEST"
  maximum_event_age_in_seconds = 21600
  maximum_retry_attempts       = 0
}
