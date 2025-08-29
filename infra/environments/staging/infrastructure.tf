locals {
  environment      = "staging"
  region           = "ap-northeast-1"
  vpc_cidr_block   = "10.10.0.0/16"
  root_domain      = "revenge-games.com"
  project          = "revengegames"
  available_zones  = ["ap-northeast-1a", "ap-northeast-1c"]
  allstar_domain   = "all-star.games"
  rectangle_domain = "rectangle-games.com"
  pxplay_domain    = "pxplaygaming.com"
}

provider "aws" {
  region = local.region
}

module "staging_networking" {
  source = "../../modules/networking"
  providers = {
    aws = aws.current
  }
  app_env         = local.environment
  cidr_block      = local.vpc_cidr_block
  available_zones = local.available_zones
}

# TODO: extract to db module
resource "aws_db_subnet_group" "this" {
  name_prefix = "${local.environment}-"
  subnet_ids = [
    module.staging_networking.subnet_private_1.id,
    module.staging_networking.subnet_private_2.id
  ]

  tags = {
    Environment = "${local.environment}"
  }
}


# Required for DMS
resource "aws_rds_cluster_parameter_group" "staging_rds_postgresql" {
  name   = local.environment
  family = "aurora-postgresql15"

  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements,pglogical"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "synchronous_commit"
    value = "ON"
  }
}

resource "aws_rds_cluster" "staging_main" {
  cluster_identifier_prefix = "${local.environment}-"

  engine         = "aurora-postgresql"
  engine_mode    = "provisioned"
  engine_version = "15" # Required as DMS only support v15

  db_subnet_group_name = aws_db_subnet_group.this.name

  master_username             = "sqladmin"
  manage_master_user_password = true

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.staging_rds_postgresql.name

  backup_retention_period         = 7
  enabled_cloudwatch_logs_exports = ["postgresql"]
  skip_final_snapshot             = true

  serverlessv2_scaling_configuration {
    max_capacity = 8.0
    min_capacity = 0.5
  }

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_rds_cluster_instance" "staging_main_primary" {
  cluster_identifier = aws_rds_cluster.staging_main.id

  identifier_prefix = "${local.environment}-"
  instance_class    = "db.serverless"

  engine         = aws_rds_cluster.staging_main.engine
  engine_version = aws_rds_cluster.staging_main.engine_version

  performance_insights_enabled = true

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_iam_role" "staging_service" {
  name = "${local.environment}-service"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonOpenSearchServiceFullAccess",
    "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [
          "ecs-tasks.amazonaws.com",
          "ecs.amazonaws.com",
          "dms.ap-northeast-1.amazonaws.com"
        ]
      }
    }]
  })

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_iam_role_policy" "staging_service_policy" {
  name = "${local.environment}-services-policies"
  role = aws_iam_role.staging_service.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "secretsmanager:GetSecretValue",
      ]
      Effect = "Allow"
      Resource = [
        "arn:aws:secretsmanager:*:*:secret:${local.environment}/*",
        aws_rds_cluster.staging_main.master_user_secret[0].secret_arn,
        "arn:aws:secretsmanager:ap-northeast-1:211125478834:secret:consumer/firehose-Or0U0z"
      ]
      }, {
      Action = [
        "logs:CreateLogStream",
        "logs:CreateLogDelivery",
        "logs:CreateLogGroup",
        "logs:PutLogEvents",
        "logs:Link",
        "logs:PutDeliveryDestination",
        "logs:PutDeliveryDestinationPolicy",
        "logs:PutDeliverySource",
        "logs:PutDestination",
        "logs:PutDestinationPolicy",
        "logs:UpdateLogDelivery",
        "logs:UpdateAnomaly",
        "logs:TagLogGroup"
      ]
      Effect = "Allow"
      Resource = [
        "arn:aws:logs:*:*:log-group:${local.environment}-*",
        "arn:aws:logs:*:*:log-group:dms-tasks-${local.environment}-*",
        "arn:aws:logs:*:*:log-group:/aws/ecs/*"
      ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObjectAcl",
          "s3:GetObject",
          "s3:GetObjectTagging",
          "s3:ListBucket",
          "s3:PutObjectTagging",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::revengegames-staging",
          "arn:aws:s3:::revengegames-staging/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:*",
          "ses:SendEmail",
          "s3:PutObject"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:GetFunction",
          "lambda:InvokeFunction"
        ]
        Resource = [
          "arn:aws:lambda:*:*:function:staging-logic-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cassandra:Select",
          "cassandra:Create",
          "cassandra:Modify"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:ListShards",
          "kinesis:PutRecord",
          "kinesis:DescribeStreamConsumer",
          "kinesis:RegisterStreamConsumer",
          "kinesis:SubscribeToShard"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable",
          "dynamodb:ConditionCheckItem",
          "dynamodb:ListTables",
          "dynamodb:DescribeReservedCapacity",
          "dynamodb:DescribeReservedCapacityOfferings"
        ]
        Resource = [
          "*"
        ]
    }]
  })
}

resource "aws_s3_bucket" "logs_sandbox" {
  bucket = "revengegames-alb-sandbox"

  tags = {
    Environment = "sandbox"
  }
}

resource "aws_s3_bucket_policy" "logs_sandbox_policy" {
  bucket = aws_s3_bucket.logs_sandbox.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::582318560864:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.logs_sandbox.id}/*"
    }
  ]
}
POLICY
}

resource "aws_lb" "staging" {
  name               = local.environment
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    module.staging_networking.vpc.default_security_group_id,
    "sg-0451a8d81062384aa",
    "sg-0b8f1a9e78b3e6ecd",
    "sg-0e66f8458a4ffd161",
    "sg-0cc6a53fa07809e33",
  ]
  subnets = [
    module.staging_networking.subnet_public_1.id,
    module.staging_networking.subnet_public_2.id
  ]

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.logs_sandbox.id
    prefix  = "access-logs"
    enabled = true
  }

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.staging.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
}

resource "aws_security_group_rule" "cloudflare" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  description = "Allow CloudFlare IPs to access the ALB"
  cidr_blocks = [
    "173.245.48.0/20",
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "141.101.64.0/18",
    "108.162.192.0/18",
    "190.93.240.0/20",
    "188.114.96.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "162.158.0.0/15",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "172.64.0.0/13",
  "131.0.72.0/22"]
  ipv6_cidr_blocks = [
    "2400:cb00::/32",
    "2606:4700::/32",
    "2803:f800::/32",
    "2405:b500::/32",
    "2405:8100::/32",
    "2a06:98c0::/29",
  "2c0f:f248::/32"]
  security_group_id = module.staging_networking.vpc.default_security_group_id
}

resource "aws_security_group_rule" "rds" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  description       = "Allow private subnets to access RDS"
  cidr_blocks       = [module.staging_networking.vpc.cidr_block]
  security_group_id = module.staging_networking.vpc.default_security_group_id
}


data "cloudflare_zone" "root" {
  name = "revenge-games.com"
}

data "cloudflare_zone" "allstar" {
  name = "all-star.games"
}

data "cloudflare_zone" "rectangle" {
  name = "rectangle-games.com"
}

# data "cloudflare_zone" "pxplay" {
#   name = "pxplaygaming.com"
# }

###############
### alb private
###############
resource "aws_lb" "staging_private" {
  name               = "${local.environment}-lambda"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.staging_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.staging_networking.subnet_private_1.id,
    module.staging_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private" {
  load_balancer_arn = aws_lb.staging_private.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
  depends_on = [aws_lb.staging_private]
}



# resource "aws_dynamodb_table" "staging_player_attributes" {
#   name         = "${local.environment}_player_attributes"
#   billing_mode = "PAY_PER_REQUEST"

#   hash_key = "Id"

#   attribute {
#     name = "Id"
#     type = "S"
#   }

#   # Optional: Tags
#   tags = {
#     Environment = "${local.environment}"
#   }
# }



#################
## ACM for all-star.games
################
module "wildcard_cert_astar" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.${local.allstar_domain}"
  #   subject_alternative_names = [
  #     "*.${var.domain}"
  #   ]

  zone_id = data.cloudflare_zone.allstar.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.us-e-1
  }

}

resource "cloudflare_record" "validation_astar" {
  count = length(module.wildcard_cert_astar.distinct_domain_names)

  zone_id = data.cloudflare_zone.allstar.id
  name    = element(module.wildcard_cert_astar.validation_domains, count.index)["resource_record_name"]
  type    = element(module.wildcard_cert_astar.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.wildcard_cert_astar.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}

resource "cloudflare_record" "prod_launcher_astar" {
  zone_id = data.cloudflare_zone.allstar.id
  name    = "launcher"
  content = "d3odsfxenzfl5x.cloudfront.net"
  type    = "CNAME"
  proxied = false
}



#################
## ACM for rectangle-games.com
################
module "wildcard_cert_rectangle" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.${local.rectangle_domain}"
  #   subject_alternative_names = [
  #     "*.${var.domain}"
  #   ]

  zone_id = data.cloudflare_zone.rectangle.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.us-e-1
  }

}


resource "cloudflare_record" "validation_rectangle" {
  count = length(module.wildcard_cert_rectangle.distinct_domain_names)

  zone_id = data.cloudflare_zone.rectangle.id
  name    = element(module.wildcard_cert_rectangle.validation_domains, count.index)["resource_record_name"]
  type    = element(module.wildcard_cert_rectangle.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.wildcard_cert_rectangle.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}

resource "cloudflare_record" "prod_launcher_rectangle" {
  zone_id = data.cloudflare_zone.rectangle.id
  name    = "launcher"
  content = "d31654qhz4ea0s.cloudfront.net"
  type    = "CNAME"
  proxied = false
}


### alb private
resource "aws_lb" "staging_private2" {
  name               = "${local.environment}-lambda-2"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.staging_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.staging_networking.subnet_private_1.id,
    module.staging_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private2" {
  load_balancer_arn = aws_lb.staging_private2.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
  depends_on = [aws_lb.staging_private2]
}


###############
### alb private3
###############
resource "aws_lb" "staging_private3" {
  name               = "${local.environment}-lambda-3"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.staging_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.staging_networking.subnet_private_1.id,
    module.staging_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private3" {
  load_balancer_arn = aws_lb.staging_private3.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
  depends_on = [aws_lb.staging_private3]
}



module "security_group" {
  source = "../../modules/security-group"
  vpc_id = module.staging_networking.vpc.id
  tags = {
    Environment = "${local.environment}"
  }
}


###### alb sg import
resource "aws_security_group" "alb" {
  name        = "staging-alb-sg"
  description = "Managed by Terraform"
  vpc_id      = "vpc-0767ff1e38b35b38b"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    description      = ""
  }

  ingress {
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["10.10.0.0/16"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    description      = "Allow to access RDS"
  }

  ingress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = ["sg-0673874673cb314d3"]
    self             = false
    description      = "Allow bastion"
  }

  ingress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = true
    description      = "Allow self"
  }

  ingress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = []
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = ["sg-0cb58950ed1a8e36f"]
    self             = false
    description      = "Allow other resources in VPC"
  }

  tags = {
    Name = "staging-alb-sg"
  }
}



###############
### alb private 4
###############
resource "aws_lb" "staging_private4" {
  name               = "${local.environment}-lambda-4"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.staging_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.staging_networking.subnet_private_1.id,
    module.staging_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private4" {
  load_balancer_arn = aws_lb.staging_private4.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
  depends_on = [aws_lb.staging_private4]
}


###############
### alb private 4
###############
resource "aws_lb" "staging_private5" {
  name               = "${local.environment}-lambda-5"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.staging_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.staging_networking.subnet_private_1.id,
    module.staging_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private5" {
  load_balancer_arn = aws_lb.staging_private5.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
  depends_on = [aws_lb.staging_private5]
}

