<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eventbridge_trigger_lambda"></a> [eventbridge\_trigger\_lambda](#module\_eventbridge\_trigger\_lambda) | ./eventbridge | n/a |
| <a name="module_lambda_batch_24h"></a> [lambda\_batch\_24h](#module\_lambda\_batch\_24h) | ./lambda | n/a |
| <a name="module_lambda_python_zip_deployment_notification"></a> [lambda\_python\_zip\_deployment\_notification](#module\_lambda\_python\_zip\_deployment\_notification) | ./lambda-python-zip | n/a |
| <a name="module_lambda_to_telegram_role"></a> [lambda\_to\_telegram\_role](#module\_lambda\_to\_telegram\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role | v5.33.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | n/a | `string` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | n/a | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | n/a | yes |
| <a name="input_lambda_function_code_path"></a> [lambda\_function\_code\_path](#input\_lambda\_function\_code\_path) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | n/a |
| <a name="output_lambda_function_invoke_arn"></a> [lambda\_function\_invoke\_arn](#output\_lambda\_function\_invoke\_arn) | n/a |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | modules/lambda/outputs.tf |
<!-- END_TF_DOCS -->