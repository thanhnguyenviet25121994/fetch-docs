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
| <a name="module_ec2_instances"></a> [ec2\_instances](#module\_ec2\_instances) | terraform-aws-modules/ec2-instance/aws | v4.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | n/a | `string` | n/a | yes |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | n/a | `string` | n/a | yes |
| <a name="input_instances"></a> [instances](#input\_instances) | Map of services | <pre>map(object({<br>    name          = string<br>    instance_type = string<br>    volume_size   = number<br>  }))</pre> | n/a | yes |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | n/a | <pre>object({<br>    subnets         = string,<br>    security_groups = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | n/a | yes |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->