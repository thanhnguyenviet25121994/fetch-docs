<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_url.services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url) | resource |
| [aws_lambda_permission.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lb_listener_rule.services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_dns_name"></a> [alb\_dns\_name](#input\_alb\_dns\_name) | n/a | `string` | n/a | yes |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | n/a | `any` | n/a | yes |
| <a name="input_enable_vpc"></a> [enable\_vpc](#input\_enable\_vpc) | Whether to deploy the Lambda function inside a VPC. | `bool` | `true` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | n/a | `string` | `"build/server.handler"` | no |
| <a name="input_lambda_event_source_mapping_sqs"></a> [lambda\_event\_source\_mapping\_sqs](#input\_lambda\_event\_source\_mapping\_sqs) | n/a | `map` | `{}` | no |
| <a name="input_lambda_function_layers"></a> [lambda\_function\_layers](#input\_lambda\_function\_layers) | n/a | `list` | `[]` | no |
| <a name="input_lambda_function_reserved_concurrent_executions"></a> [lambda\_function\_reserved\_concurrent\_executions](#input\_lambda\_function\_reserved\_concurrent\_executions) | n/a | `number` | `-1` | no |
| <a name="input_lambda_function_timeout"></a> [lambda\_function\_timeout](#input\_lambda\_function\_timeout) | n/a | `number` | `60` | no |
| <a name="input_lambda_permission_api_gateway"></a> [lambda\_permission\_api\_gateway](#input\_lambda\_permission\_api\_gateway) | variable "lambda\_function\_environment" { default = [] } | `map` | `{}` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | lambda | `string` | `"nodejs20.x"` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | n/a | `number` | `128` | no |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | n/a | <pre>object({<br>    vpc_id          = string,<br>    subnets         = list(string),<br>    security_groups = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_private_routes"></a> [private\_routes](#input\_private\_routes) | n/a | <pre>object({<br>    enabled     = bool,<br>    root_domain = string,<br>    load_balancer_listener = object({<br>      arn               = string<br>      load_balancer_arn = string<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_services"></a> [services](#input\_services) | Map of services | <pre>map(object({<br>    env                  = map(string)<br>    handler              = string<br>    lambda_architectures = list(string)<br>    memory_size          = number<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_function_urls"></a> [lambda\_function\_urls](#output\_lambda\_function\_urls) | The URL of the Lambda function for each service. |
<!-- END_TF_DOCS -->