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
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_cloudfront_distribution.s3_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | The name given to the environment | `string` | `null` | no |
| <a name="input_cache_policy_id"></a> [cache\_policy\_id](#input\_cache\_policy\_id) | The cache policy ID | `string` | `""` | no |
| <a name="input_lambda_arn"></a> [lambda\_arn](#input\_lambda\_arn) | The ARN of the Lambda function | `string` | `""` | no |
| <a name="input_lambda_arn_staging"></a> [lambda\_arn\_staging](#input\_lambda\_arn\_staging) | The response\_headers\_policy\_id | `string` | `""` | no |
| <a name="input_origin_domain_elb"></a> [origin\_domain\_elb](#input\_origin\_domain\_elb) | The domain name of the ELB | `string` | n/a | yes |
| <a name="input_origin_request_policy_id"></a> [origin\_request\_policy\_id](#input\_origin\_request\_policy\_id) | The origin request policy ID | `string` | `""` | no |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | Price class | `string` | `"PriceClass_All"` | no |
| <a name="input_response_headers_policy_id"></a> [response\_headers\_policy\_id](#input\_response\_headers\_policy\_id) | The response\_headers\_policy\_id | `string` | `""` | no |
| <a name="input_root_domain"></a> [root\_domain](#input\_root\_domain) | Root domain | `string` | n/a | yes |
| <a name="input_s3_website_endpoint"></a> [s3\_website\_endpoint](#input\_s3\_website\_endpoint) | The S3 website endpoint | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_distribution_domain_name"></a> [cloudfront\_distribution\_domain\_name](#output\_cloudfront\_distribution\_domain\_name) | n/a |
<!-- END_TF_DOCS -->