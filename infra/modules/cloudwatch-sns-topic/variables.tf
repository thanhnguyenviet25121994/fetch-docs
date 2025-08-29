variable "environment" {
  description = "The name given to the environment"
  type        = string
  default     = null
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "sns_topic_name" {
  description = "The name of the SNS topic"
  type        = string
}

variable "LARK_WEBHOOK_URL" {
  description = "The webhook url of the lark bot"
  type        = string
}
