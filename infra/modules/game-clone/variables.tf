variable "domain" {
  type = string
}

variable "app_env" {
  type = string
}
variable "alb_dns_name" {
  type = string
}
variable "acm_certificate_arn" {
  type = string
}

variable "logging_config" {
  type = map(string)
  default = {
  }
}