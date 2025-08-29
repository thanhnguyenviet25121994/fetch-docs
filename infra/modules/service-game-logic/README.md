<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_container_definitions_services"></a> [container\_definitions\_services](#module\_container\_definitions\_services) | ../task-definition | n/a |
| <a name="module_ecs_service_services"></a> [ecs\_service\_services](#module\_ecs\_service\_services) | terraform-aws-modules/ecs/aws//modules/service | v5.11.2 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_lb_listener_rule.services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [cloudflare_record.services](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [aws_lb.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [cloudflare_zone.root](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | n/a | `string` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | n/a | `string` | `"service-game-logic"` | no |
| <a name="input_env"></a> [env](#input\_env) | n/a | `map(string)` | `{}` | no |
| <a name="input_image"></a> [image](#input\_image) | n/a | `string` | `""` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | n/a | <pre>object({<br>    min = number,<br>    max = number<br>  })</pre> | <pre>{<br>  "max": 32,<br>  "min": 1<br>}</pre> | no |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | n/a | <pre>object({<br>    vpc = object({<br>      id = string<br>    })<br>    region          = string<br>    subnets         = list(string),<br>    security_groups = list(string),<br>    load_balancer_target_groups = list(object({<br>      arn  = string<br>      port = number<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_public_routes"></a> [public\_routes](#input\_public\_routes) | n/a | <pre>object({<br>    enabled     = bool,<br>    root_domain = string,<br>    load_balancer_listener = object({<br>      arn               = string<br>      load_balancer_arn = string<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_role"></a> [role](#input\_role) | n/a | <pre>object({<br>    arn = string<br>  })</pre> | n/a | yes |
| <a name="input_services"></a> [services](#input\_services) | Map of services | <pre>map(object({<br>    image = string<br>    env = list(object({<br>      name  = string<br>      value = string<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_task_size_cpu"></a> [task\_size\_cpu](#input\_task\_size\_cpu) | n/a | `string` | `256` | no |
| <a name="input_task_size_memory"></a> [task\_size\_memory](#input\_task\_size\_memory) | n/a | `string` | `512` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->