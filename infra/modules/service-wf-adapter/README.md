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
| <a name="module_container_definition_service"></a> [container\_definition\_service](#module\_container\_definition\_service) | ../task-definition | n/a |
| <a name="module_ecs_svc_service"></a> [ecs\_svc\_service](#module\_ecs\_svc\_service) | terraform-aws-modules/ecs/aws//modules/service | v5.11.2 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | n/a | `string` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | n/a | `string` | `"service-wf-adapter"` | no |
| <a name="input_env"></a> [env](#input\_env) | n/a | `map(string)` | `{}` | no |
| <a name="input_image"></a> [image](#input\_image) | n/a | `string` | n/a | yes |
| <a name="input_instance_count_max"></a> [instance\_count\_max](#input\_instance\_count\_max) | n/a | `number` | `256` | no |
| <a name="input_instance_count_min"></a> [instance\_count\_min](#input\_instance\_count\_min) | n/a | `number` | `1` | no |
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