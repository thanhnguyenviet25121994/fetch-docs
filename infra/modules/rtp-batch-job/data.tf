####################################
## Data
####################################

## VPC:


# data "aws_subnets" "this" {
#   filter {
#     name   = "vpc-id"
#     values = [var.vpc_id]
#   }

#   filter {
#     name   = "tag:env"
#     values = ["${var.prefix}"]
#   }

#   filter {
#     name   = "tag:app"
#     values = ["${var.tenant_name}-${var.app_name}"]
#   }

#   filter {
#     name   = "tag:type"
#     values = ["private"]
#   }
# }

## ECR:
# data "aws_organizations_organization" "this" {}
# data "aws_ecr_repository" "this" {
#   name        = var.batch_configs.repository_name
#   registry_id = data.aws_organizations_organization.this.master_account_id
# }
