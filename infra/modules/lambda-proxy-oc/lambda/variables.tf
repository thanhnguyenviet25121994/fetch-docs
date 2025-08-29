#modules/lambda/variables.tf
#basic
# variable "project" {}
variable "env" {}
variable "region" {}

#lambda
variable "lambda_runtime" {
  type    = string
  default = "python3.12"
}
variable "lambda_function_name" {}
variable "lambda_function_filename" {}
variable "lambda_function_handler" {}
variable "lambda_function_role" {}
variable "lambda_function_timeout" { default = 60 }
variable "lambda_function_layers" { default = [] }
variable "lambda_function_reserved_concurrent_executions" { default = -1 }
variable "lambda_function_environment" { default = [] }
variable "lambda_permission_api_gateway" { default = {} }
variable "lambda_event_source_mapping_sqs" { default = {} }
