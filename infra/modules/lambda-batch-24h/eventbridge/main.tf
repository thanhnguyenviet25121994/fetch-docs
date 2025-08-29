
resource "aws_scheduler_schedule" "this" {
  name  = "schedule_${var.name}"
  state = var.scheduler_state

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.schedule_expression_timezone

  target {
    arn      = var.lambda_function_arn
    role_arn = aws_iam_role.this.arn

    input = var.target_input
  }
}

resource "aws_iam_role" "this" {
  name = "ir.eventbridge_invoke_lambda_${var.lambda_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "this" {
  name = "ip.eventbridge_invoke_lambda_${var.lambda_name}"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = var.lambda_function_arn
      },
    ]
  })
}


variable "name" {
  type = string
}
variable "lambda_name" {
  type = string
}
variable "schedule_expression" {
  type = string
}

variable "lambda_function_arn" {
  type = string
}

variable "target_input" {
  type = string
}
variable "scheduler_state" {
  type    = string
  default = "ENABLED"
}

variable "schedule_expression_timezone" {
  type = string
}
