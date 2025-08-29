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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | n/a | `string` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | n/a | `string` | `"service-static-router"` | no |
| <a name="input_config_url"></a> [config\_url](#input\_config\_url) | n/a | `string` | n/a | yes |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | n/a | `number` | `1` | no |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | n/a | <pre>object({<br>    region          = string<br>    subnets         = list(string),<br>    security_groups = list(string),<br>    load_balancer_target_groups = list(object({<br>      arn  = string,<br>      port = number<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_role"></a> [role](#input\_role) | n/a | <pre>object({<br>    arn = string<br>  })</pre> | n/a | yes |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | n/a | `number` | `256` | no |
| <a name="input_task_mem"></a> [task\_mem](#input\_task\_mem) | n/a | `number` | `512` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->