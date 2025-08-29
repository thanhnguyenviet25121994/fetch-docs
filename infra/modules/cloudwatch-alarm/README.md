<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.generic_alarm_with_metric_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.generic_alarm_with_metric_query](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | A list of ARNs (Amazon Resource Names) specifying the actions to execute when this alarm transitions to an ALARM state from any other state. | `list(string)` | `[]` | no |
| <a name="input_alarm_description"></a> [alarm\_description](#input\_alarm\_description) | The description for the alarm | `string` | n/a | yes |
| <a name="input_alarm_name"></a> [alarm\_name](#input\_alarm\_name) | The descriptive name for the alarm | `string` | n/a | yes |
| <a name="input_comparison_operator"></a> [comparison\_operator](#input\_comparison\_operator) | The arithmetic operation to use when comparing the specified Statistic and Threshold | `string` | n/a | yes |
| <a name="input_datapoints_to_alarm"></a> [datapoints\_to\_alarm](#input\_datapoints\_to\_alarm) | The number of data points that must be breaching to trigger the alarm | `string` | `null` | no |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | The dimensions for the alarm's associated metric | `map(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The name given to the environment | `string` | `null` | no |
| <a name="input_evaluation_periods"></a> [evaluation\_periods](#input\_evaluation\_periods) | The number of periods over which data is compared to the specified threshold | `string` | n/a | yes |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | A list of ARNs (Amazon Resource Names) specifying the actions to execute when this alarm transitions to an INSUFFICIENT\_DATA state from any other state. | `list(string)` | `[]` | no |
| <a name="input_metric_name"></a> [metric\_name](#input\_metric\_name) | The name of the metric for the alarm if no metric queries are provided. | `string` | `""` | no |
| <a name="input_metric_queries"></a> [metric\_queries](#input\_metric\_queries) | List of metric queries for the CloudWatch alarm | <pre>list(object({<br>    id          = string<br>    expression  = optional(string)<br>    label       = string<br>    return_data = bool<br>    metric = optional(object({<br>      metric_name = optional(string)<br>      namespace   = string<br>      period      = number<br>      stat        = string<br>      unit        = string<br>      dimensions  = map(string)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace for the alarm's associated metric | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | A list of ARNs (Amazon Resource Names) specifying the actions to execute when this alarm transitions to an OK state from any other state. | `list(string)` | `[]` | no |
| <a name="input_period"></a> [period](#input\_period) | The period in seconds over which the specified statistic is applied | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_statistic"></a> [statistic](#input\_statistic) | The statistic to apply to the alarm's associated metric | `string` | n/a | yes |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | The value against which the specified statistic is compared | `string` | n/a | yes |
| <a name="input_treat_missing_data"></a> [treat\_missing\_data](#input\_treat\_missing\_data) | The action to take when the metric is missing | `string` | `"missing"` | no |
| <a name="input_type"></a> [type](#input\_type) | Type of the CloudWatch alarm configuration. Use 1 for metric\_name and 2 for metric\_query. | `number` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->