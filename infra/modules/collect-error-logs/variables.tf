variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "environment" {
  description = "The environment to deploy resources in"
  type        = string
}

variable "log_group_name" {
  description = "The name of the CloudWatch Logs group to subscribe to"
  type        = string
}

variable "lark_webhook_url" {
  description = "The Lark webhook URL to send alerts to"
  type        = string
}

variable "filter_pattern" {
  description = "The filter pattern to use for the CloudWatch Logs subscription"
  type        = string
}