output "lambda_function_urls" {
  value       = { for service, details in aws_lambda_function_url.services : service => details.function_url }
  description = "The URL of the Lambda function for each service."
}

output "lambda_function_names" {
  value = { for name, lambda in aws_lambda_function.lambda_function : name => lambda.function_name }
}