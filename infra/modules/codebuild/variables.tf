variable "create" {
  description = "Controls whether resources should be created"
  type        = bool
  default     = true
}

# variable "tenants" {
#   type = map(object({
#     account_id        = string
#     stage_bucket_name = string
#     prod_bucket_name  = string
#   }))
# }

# variable "prefix" {
#   type        = string
#   description = "prefix for dev|stage|prod env"
# }

variable "app_name" {
  type        = string
  description = "application name"
  default     = "test"
}

# variable "vendor_name" {
#   type        = string
#   default     = "archetype-digital"
#   description = "vendor name of artifact"
# }

# variable "frontend_name" {
#   type        = string
#   description = "s3 frontend name"
# }

# variable "stage_package_version" {
#   type        = string
#   default     = "dev"
#   description = "package version"
# }

# variable "prod_package_version" {
#   type        = string
#   default     = "latest"
#   description = "package version"
# }

# variable "main_region" {
#   type = string
# }

# variable "iam_cdb_arn" {
#   type        = string
#   description = "IAM Role Arn of CodeBuild"
# }

# variable "iam_cdp_arn" {
#   type        = string
#   description = "IAM Role Arn of CodePipeline"
# }

# variable "iam_cwe_arn" {
#   type        = string
#   description = "IAM Role Arn of CloudWatch Event"
# }

# variable "sns_topic" {
#   type        = string
#   description = "SNS Topic for sending notifications to admin"
# }
