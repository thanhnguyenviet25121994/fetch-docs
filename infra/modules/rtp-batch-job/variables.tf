variable "created" {
  type        = bool
  default     = true
  description = "Whether to create resources"
}

variable "main_region" {
  type        = string
  default     = "ap-southeast-1"
  description = "The aws region of resources"
}


variable "subnet_id" {
  type = string
}


variable "prefix" {
  type        = string
  description = "prefix for dev|stage|prod env"
}

variable "vpc_id" {
  type        = string
  description = "vpc id"
}

variable "app_name" {
  type        = string
  description = "application name"
}

variable "batch_configs" {
  type        = any
  description = "Map of batch config"
}

variable "create_service_iam_role" {
  type        = bool
  default     = true
  description = "Whether to create a service IAM role"

}

variable "create_instance_iam_role" {
  type        = bool
  default     = false
  description = "Whether to create a instance IAM role"
}

variable "create_spot_fleet_iam_role" {
  type        = bool
  default     = false
  description = "Whether to create a spot fleet IAM role"
}