#modules/lambda/outputs.tf
output "lambda_function_name" {
  value = module.filter_log_to_lark_notification.lambda_function_name
}
output "lambda_function_arn" {
  value = module.filter_log_to_lark_notification.lambda_function_arn
}
output "lambda_function_invoke_arn" {
  value = module.filter_log_to_lark_notification.lambda_function_invoke_arn
}
