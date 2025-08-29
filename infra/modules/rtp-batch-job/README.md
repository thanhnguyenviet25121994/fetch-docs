## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_batch_compute_environment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_compute_environment) | resource |
| [aws_batch_job_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_job_definition) | resource |
| [aws_batch_job_queue.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_job_queue) | resource |
| [aws_iam_instance_profile.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.spot_fleet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.spot_fleet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_repository) | data source |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_subnets.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpcs.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpcs) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | application name | `string` | n/a | yes |
| <a name="input_batch_configs"></a> [batch\_configs](#input\_batch\_configs) | Map of batch config | `any` | n/a | yes |
| <a name="input_create_instance_iam_role"></a> [create\_instance\_iam\_role](#input\_create\_instance\_iam\_role) | Whether to create a instance IAM role | `bool` | `false` | no |
| <a name="input_create_service_iam_role"></a> [create\_service\_iam\_role](#input\_create\_service\_iam\_role) | Whether to create a service IAM role | `bool` | `true` | no |
| <a name="input_create_spot_fleet_iam_role"></a> [create\_spot\_fleet\_iam\_role](#input\_create\_spot\_fleet\_iam\_role) | Whether to create a spot fleet IAM role | `bool` | `false` | no |
| <a name="input_created"></a> [created](#input\_created) | Whether to create resources | `bool` | `true` | no |
| <a name="input_main_region"></a> [main\_region](#input\_main\_region) | The aws region of resources | `string` | `"ap-northeast-1"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | prefix for dev\|stage\|prod env | `string` | n/a | yes |
| <a name="input_tenant_name"></a> [tenant\_name](#input\_tenant\_name) | tenant name that is supposed to be partner/customer name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cwe_rule_name"></a> [cwe\_rule\_name](#output\_cwe\_rule\_name) | The cloudwatch rule's prefix name will be used |
| <a name="output_job_definition"></a> [job\_definition](#output\_job\_definition) | Map of job defintions created and their associated attributes |
| <a name="output_job_definition_arn"></a> [job\_definition\_arn](#output\_job\_definition\_arn) | The Amazon Resource Name of the job definition |
| <a name="output_job_definition_name"></a> [job\_definition\_name](#output\_job\_definition\_name) | The Name of the job definition |
| <a name="output_job_queue"></a> [job\_queue](#output\_job\_queue) | Map of job queues created and their associated attributes |

## Usages:
------
#### Type is FARGATE or FARGATE_SPOT:
- Use `var.created` as `'true'`, and `var.create_service_iam_role` as `'true'` (default).

#### Type is 'EC2':
- Please set `var.create_instance_iam_role` as `'true'` in additional settings.

#### Type is 'SPOT':
- Please set `var.create_spot_fleet_iam_role` as `'true'` in additional settings.

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
| [aws_batch_compute_environment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_compute_environment) | resource |
| [aws_batch_job_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_job_definition) | resource |
| [aws_batch_job_queue.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_job_queue) | resource |
| [aws_iam_instance_profile.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.jobrole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.spot_fleet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.jobrole_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.task_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.spot_fleet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | application name | `string` | n/a | yes |
| <a name="input_batch_configs"></a> [batch\_configs](#input\_batch\_configs) | Map of batch config | `any` | n/a | yes |
| <a name="input_create_instance_iam_role"></a> [create\_instance\_iam\_role](#input\_create\_instance\_iam\_role) | Whether to create a instance IAM role | `bool` | `false` | no |
| <a name="input_create_service_iam_role"></a> [create\_service\_iam\_role](#input\_create\_service\_iam\_role) | Whether to create a service IAM role | `bool` | `true` | no |
| <a name="input_create_spot_fleet_iam_role"></a> [create\_spot\_fleet\_iam\_role](#input\_create\_spot\_fleet\_iam\_role) | Whether to create a spot fleet IAM role | `bool` | `false` | no |
| <a name="input_created"></a> [created](#input\_created) | Whether to create resources | `bool` | `true` | no |
| <a name="input_main_region"></a> [main\_region](#input\_main\_region) | The aws region of resources | `string` | `"ap-southeast-1"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | prefix for dev\|stage\|prod env | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | n/a | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | vpc id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cwe_rule_name"></a> [cwe\_rule\_name](#output\_cwe\_rule\_name) | The cloudwatch rule's prefix name will be used |
| <a name="output_job_definition"></a> [job\_definition](#output\_job\_definition) | Map of job defintions created and their associated attributes |
| <a name="output_job_definition_arn"></a> [job\_definition\_arn](#output\_job\_definition\_arn) | The Amazon Resource Name of the job definition |
| <a name="output_job_definition_name"></a> [job\_definition\_name](#output\_job\_definition\_name) | The Name of the job definition |
| <a name="output_job_queue"></a> [job\_queue](#output\_job\_queue) | Map of job queues created and their associated attributes |
<!-- END_TF_DOCS -->