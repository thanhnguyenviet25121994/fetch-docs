################################
# Variables
################################

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "sa-east-1"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "alb-log-monitor"
}

variable "log_prefix" {
  description = "Prefix for ALB logs in S3"
  type        = string
  default     = "access-logs/prod/"
}

variable "send_to_lark" {
  description = "Whether to send results to Lark bot"
  type        = string
  default     = "true"
}

variable "hours_to_analyze" {
  description = "Number of hours to analyze logs"
  type        = string
  default     = "6"
}

variable "log_bucket_name" {
  description = "Access log bucket name"
  type        = string
  default     = "alb-revengegames-prod"
}

variable "app_env" {}

variable "network_configuration" {
  type = object({
    vpc_id          = string,
    subnets         = list(string),
    security_groups = list(string)
  })
}