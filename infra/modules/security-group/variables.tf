variable "vpc_id" {
  description = "VPC ID "
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}
