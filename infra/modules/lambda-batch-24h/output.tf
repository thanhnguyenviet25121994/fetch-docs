#modules/lambda/outputs.tf
output "lambda_function_name" {
  value = module.lambda_batch_24h.lambda_function_name
}
output "lambda_function_arn" {
  value = module.lambda_batch_24h.lambda_function_arn
}
output "lambda_function_invoke_arn" {
  value = module.lambda_batch_24h.lambda_function_invoke_arn
}
