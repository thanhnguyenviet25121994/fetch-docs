variable "services" {
  description = "Map of services"
  type = map(object({
    env                  = map(string)
    handler              = string
    lambda_architectures = list(string)
    memory_size          = number
  }))
}

variable "network_configuration" {
  type = object({
    vpc_id          = string,
    subnets         = list(string),
    security_groups = list(string)
  })
}
# each.key == "logic-lucky-tiger-clone" ? ["x86_64"] : ["arm64"]

variable "enable_vpc" {
  description = "Whether to deploy the Lambda function inside a VPC."
  type        = bool
  default     = true
}

variable "global_domain" {
  type = string
}

variable "region" {
  type = string
}


variable "private_routes" {
  type = object({
    enabled     = bool,
    root_domain = string,
    load_balancer_listener = object({
      arn               = string
      load_balancer_arn = string
    })
  })
}

# variable "public_routes" {
#   type = object({
#     enabled     = bool,
#     root_domain = string
#   })
# }


variable "memory_size" {
  type    = number
  default = 128
}

variable "alb_dns_name" {
  type = string
}

variable "handler" {
  type    = string
  default = "build/server.handler"
}
variable "app_env" {}

#lambda
variable "lambda_runtime" {
  type    = string
  default = "nodejs20.x"
}
variable "lambda_function_timeout" { default = 60 }
variable "lambda_function_layers" { default = [] }
variable "lambda_function_reserved_concurrent_executions" { default = -1 }
# variable "lambda_function_environment" { default = [] }
variable "lambda_permission_api_gateway" { default = {} }
variable "lambda_event_source_mapping_sqs" { default = {} }
