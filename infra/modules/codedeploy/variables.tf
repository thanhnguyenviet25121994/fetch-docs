variable "app_name" {
  type = string
}
variable "ecs_cluster_name" {
  type = string
}
variable "ecs_service_name" {
  type = string
}

variable "alb_listener_arn" {
  type = string
}
variable "target_group_blue_name" {
  type = string
}
variable "target_group_green_name" {
  type = string
}
variable "env" {
  type = string
}

variable "deployment_config_name" {
  type    = string
  default = "CodeDeployDefault.ECSCanary10Percent5Minutes"
}