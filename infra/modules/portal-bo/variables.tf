
variable "app_env" {
  type = string
}

variable "app_domain" {
  type = string

}

variable "app_name" {
  type = string
}

variable "alb_dns_name" {
  type = string
}
variable "acm_certificate_arn" {
  type = string
}

variable "lambda_edge_arn" {
  type = string
}