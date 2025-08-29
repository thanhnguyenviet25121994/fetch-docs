resource "aws_cloudwatch_metric_alarm" "generic_alarm_with_metric_name" {
  count                     = var.type == 1 ? 1 : 0
  alarm_name                = var.alarm_name
  comparison_operator       = var.comparison_operator
  evaluation_periods        = var.evaluation_periods
  namespace                 = var.namespace
  period                    = var.period
  statistic                 = var.statistic
  threshold                 = var.threshold
  alarm_description         = var.alarm_description
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  datapoints_to_alarm       = var.datapoints_to_alarm
  treat_missing_data        = var.treat_missing_data
  dimensions                = var.dimensions
  metric_name               = var.metric_name

  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "generic_alarm_with_metric_query" {
  count                     = var.type == 2 ? 1 : 0
  alarm_name                = var.alarm_name
  comparison_operator       = var.comparison_operator
  evaluation_periods        = var.evaluation_periods
  threshold                 = var.threshold
  alarm_description         = var.alarm_description
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  datapoints_to_alarm       = var.datapoints_to_alarm
  treat_missing_data        = var.treat_missing_data

  dynamic "metric_query" {
    for_each = var.metric_queries
    content {
      id          = metric_query.value.id
      expression  = try(metric_query.value.expression, null)
      label       = metric_query.value.label
      return_data = metric_query.value.return_data

      dynamic "metric" {
        for_each = metric_query.value.metric != null ? [metric_query.value.metric] : []
        content {
          metric_name = try(metric.value.metric_name, null)
          namespace   = metric.value.namespace
          period      = metric.value.period
          stat        = metric.value.stat
          unit        = metric.value.unit
          dimensions  = metric.value.dimensions
        }
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}