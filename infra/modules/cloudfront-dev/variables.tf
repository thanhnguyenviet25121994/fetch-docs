variable "app_env" {
  description = "The name given to the environment"
  type        = string
  default     = null
}

variable "root_domain" {
  description = "Root domain"
  type        = string
}

variable "origin_domain_elb" {
  description = "The domain name of the ELB"
  type        = string
}

variable "price_class" {
  description = "Price class"
  type        = string
  default     = "PriceClass_All"
}

variable "cache_policy_id" {
  description = "The cache policy ID"
  type        = string
  default     = ""
}
variable "response_headers_policy_id" {
  description = "The response_headers_policy_id"
  type        = string
  default     = ""
}
variable "origin_request_policy_id" {
  description = "The origin request policy ID"
  type        = string
  default     = ""
}

variable "lambda_arn" {
  description = "The ARN of the Lambda function"
  type        = string
  default     = ""
}
variable "s3_website_endpoint" {
  description = "The S3 website endpoint"
  type        = string
  default     = ""
}

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}