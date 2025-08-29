variable "instances" {
  description = "Map of services"
  type = map(object({
    name          = string
    instance_type = string
    volume_size   = number
  }))
}

variable "app_env" {
  type = string
}

variable "user_data" {
  type = string
}

variable "network_configuration" {
  type = object({
    subnets         = string,
    security_groups = list(string)
  })
}

variable "ami" {
  type = string
}

variable "tags" {
  type = map(string)
}