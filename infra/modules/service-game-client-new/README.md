<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_container_definition_service_game_client"></a> [container\_definition\_service\_game\_client](#module\_container\_definition\_service\_game\_client) | ../task-definition | n/a |
| <a name="module_ecs_svc_service_game_client"></a> [ecs\_svc\_service\_game\_client](#module\_ecs\_svc\_service\_game\_client) | terraform-aws-modules/ecs/aws//modules/service | v5.11.2 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.otel_sidecar](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_metric_filter.error_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.error_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_sns_topic.error_notification_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | n/a | `string` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | n/a | `string` | `"service-game-client"` | no |
| <a name="input_db"></a> [db](#input\_db) | n/a | <pre>object({<br>    endpoint        = string<br>    reader_endpoint = string<br>    name            = string<br>    credentials = object({<br>      arn = string<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | n/a | `number` | `2` | no |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | n/a | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | n/a | `map(string)` | `{}` | no |
| <a name="input_filter_pattern"></a> [filter\_pattern](#input\_filter\_pattern) | n/a | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | n/a | `string` | n/a | yes |
| <a name="input_instance_count_max"></a> [instance\_count\_max](#input\_instance\_count\_max) | n/a | `number` | `256` | no |
| <a name="input_instance_count_min"></a> [instance\_count\_min](#input\_instance\_count\_min) | n/a | `number` | `2` | no |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | n/a | <pre>object({<br>    region = string<br>    vpc = object({<br>      id = string<br>    })<br>    subnets         = list(string),<br>    security_groups = list(string),<br>    load_balancer_target_groups = list(object({<br>      arn  = string,<br>      port = number<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_role"></a> [role](#input\_role) | n/a | <pre>object({<br>    arn = string<br>  })</pre> | n/a | yes |
| <a name="input_task_size_cpu"></a> [task\_size\_cpu](#input\_task\_size\_cpu) | n/a | `number` | `1024` | no |
| <a name="input_task_size_memory"></a> [task\_size\_memory](#input\_task\_size\_memory) | n/a | `number` | `2048` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_get_aws_ecs_cluster"></a> [get\_aws\_ecs\_cluster](#output\_get\_aws\_ecs\_cluster) | The ECS cluster |
| <a name="output_get_aws_ecs_service"></a> [get\_aws\_ecs\_service](#output\_get\_aws\_ecs\_service) | The ECS service |
<!-- END_TF_DOCS -->