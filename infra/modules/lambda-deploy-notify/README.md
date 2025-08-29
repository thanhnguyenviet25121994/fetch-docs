<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eventbridge_lambda_ecs_deployment_notification"></a> [eventbridge\_lambda\_ecs\_deployment\_notification](#module\_eventbridge\_lambda\_ecs\_deployment\_notification) | terraform-aws-modules/eventbridge/aws | v3.10.0 |
| <a name="module_lambda_ecs_deployment_notification"></a> [lambda\_ecs\_deployment\_notification](#module\_lambda\_ecs\_deployment\_notification) | ./lambda | n/a |
| <a name="module_lambda_python_zip_deployment_notification"></a> [lambda\_python\_zip\_deployment\_notification](#module\_lambda\_python\_zip\_deployment\_notification) | ./lambda-python-zip | n/a |
| <a name="module_lambda_to_telegram_role"></a> [lambda\_to\_telegram\_role](#module\_lambda\_to\_telegram\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role | v5.33.0 |

## Resources

| Name | Type |
|------|------|
| [aws_lambda_permission.allow_eventbridge_lambda_ecs_deployment_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | n/a | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | n/a | yes |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | n/a | `list(any)` | n/a | yes |
| <a name="input_lambda_function_code_path"></a> [lambda\_function\_code\_path](#input\_lambda\_function\_code\_path) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->