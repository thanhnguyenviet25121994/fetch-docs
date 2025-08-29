terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "app_name" {
  type    = string
  default = "opensearch"
}

variable "app_env" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "m7g.medium.search"
}

variable "engine_version" {
  type    = string
  default = "OpenSearch_2.17"

}

variable "instance_count" {
  type    = number
  default = 3
}

variable "volume_size" {
  type    = number
  default = 10
}

variable "network_configuration" {
  type = object({
    vpc = object({
      id                        = string
      default_security_group_id = string
    })
    subnet_ids = list(string)
  })
}

resource "aws_cloudwatch_log_group" "this" {
  name = "${var.app_env}-${var.app_name}"

  tags = {
    Environment = "${var.app_env}"
  }
}

# resource "aws_iam_policy" "cloudwatch" {
#   name = "${var.app_name}-cloudwatch-policy"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Action = [
#         "logs:CreateLogStream",
#         "logs:CreateLogDelivery",
#         "logs:CreateLogGroup",
#         "logs:PutLogEvents",
#         "logs:Link",
#         "logs:PutDeliveryDestination",
#         "logs:PutDeliveryDestinationPolicy",
#         "logs:PutDeliverySource",
#         "logs:PutDestination",
#         "logs:PutDestinationPolicy",
#         "logs:UpdateLogDelivery",
#         "logs:UpdateAnomaly",
#         "logs:TagLogGroup"
#       ],
#       Resource = [
#         aws_cloudwatch_log_group.this.arn
#       ]
#       Principal = {
#         Service = [
#           "opensearchservice.amazonaws.com"
#         ]
#       }
#     }]
#   })
# }

resource "aws_opensearch_domain" "this" {
  domain_name    = "${var.app_env}-${var.app_name}"
  engine_version = var.engine_version

  cluster_config {
    instance_type  = var.instance_type
    instance_count = var.instance_count
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.volume_size
  }

  vpc_options {
    subnet_ids = var.network_configuration.subnet_ids
    security_group_ids = [
      var.network_configuration.vpc.default_security_group_id
    ]
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.this.arn
    enabled                  = false
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  # log_publishing_options {
  #   cloudwatch_log_group_arn = "arn:aws:logs:${var.region}:211125478834:log-group:/aws/OpenSearchService/domains/${var.app_env}-opensearch/application-logs"
  #   enabled                  = true
  #   log_type                 = "ES_APPLICATION_LOGS"
  # }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true

    master_user_options {
      master_user_name     = "${var.app_env}master"
      master_user_password = "P@ssw0rd"
    }
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  tags = {
    Name        = "${var.app_env}-${var.app_name}"
    Environment = var.app_env
  }
}
