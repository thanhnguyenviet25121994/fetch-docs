variable "environment" {
  description = "The name given to the environment"
  type        = string
  default     = null
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "alarm_name" {
  description = "The descriptive name for the alarm"
  type        = string
}

variable "comparison_operator" {
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold"
  type        = string
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold"
  type        = string
}

variable "metric_name" {
  description = "The name of the metric for the alarm if no metric queries are provided."
  type        = string
  default     = ""
}

variable "metric_queries" {
  description = "List of metric queries for the CloudWatch alarm"
  type = list(object({
    id          = string
    expression  = optional(string)
    label       = string
    return_data = bool
    metric = optional(object({
      metric_name = optional(string)
      namespace   = string
      period      = number
      stat        = string
      unit        = string
      dimensions  = map(string)
    }))
  }))
  default = []
}

variable "namespace" {
  description = "The namespace for the alarm's associated metric"
  type        = string
}

variable "period" {
  description = "The period in seconds over which the specified statistic is applied"
  type        = string
}

variable "statistic" {
  description = "The statistic to apply to the alarm's associated metric"
  type        = string
}

variable "threshold" {
  description = "The value against which the specified statistic is compared"
  type        = string
}

variable "alarm_description" {
  description = "The description for the alarm"
  type        = string
}

variable "dimensions" {
  description = "The dimensions for the alarm's associated metric"
  type        = map(string)
}

variable "alarm_actions" {
  description = "A list of ARNs (Amazon Resource Names) specifying the actions to execute when this alarm transitions to an ALARM state from any other state."
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "A list of ARNs (Amazon Resource Names) specifying the actions to execute when this alarm transitions to an OK state from any other state."
  type        = list(string)
  default     = []
}

variable "insufficient_data_actions" {
  description = "A list of ARNs (Amazon Resource Names) specifying the actions to execute when this alarm transitions to an INSUFFICIENT_DATA state from any other state."
  type        = list(string)
  default     = []
}

variable "datapoints_to_alarm" {
  description = "The number of data points that must be breaching to trigger the alarm"
  type        = string
  default     = null
}

variable "treat_missing_data" {
  description = "The action to take when the metric is missing"
  type        = string
  default     = "missing"
}

variable "type" {
  description = "Type of the CloudWatch alarm configuration. Use 1 for metric_name and 2 for metric_query."
  type        = number
}