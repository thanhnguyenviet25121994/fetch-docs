################################
# Outputs
################################

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.alb_log_analyzer.arn
}

# output "lambda_role_arn" {
#   description = "The ARN of the IAM role used by Lambda function"
#   value       = aws_iam_role.lambda_role.arn
# }