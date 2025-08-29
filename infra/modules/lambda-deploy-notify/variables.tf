variable "app_env" {
  type = string
}

variable "aws_region" {
  type = string
}
variable "ecs_cluster_arn" {
  type = list(any)
}

variable "lambda_function_code_path" {
  type = string
}