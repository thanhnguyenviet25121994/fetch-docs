locals {
  environment     = "prd-eu"
  region          = "eu-west-1"
  vpc_cidr_block  = "10.40.0.0/16"
  root_domain     = "lnga-rg.com"
  prefix          = "eu"
  project         = "revengegames"
  rg_domain       = "rg-lgna.com"
  pgs_dns         = "1adz83lbv.com"
  hacksaw_domain  = "hacksawproduction.com"
  aw_domain       = "acewin-gaming.com"
  available_zones = ["eu-west-1a", "eu-west-1c"]
}

provider "aws" {
  region = local.region
}

module "prd_eu_networking" {
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
    module.prd_eu_networking.subnet_private_1.id,
    module.prd_eu_networking.subnet_private_2.id
  ]

  tags = {
    Environment = "${local.environment}"
  }
}

# Required for DMS
resource "aws_rds_cluster_parameter_group" "prd_eu_rds_postgresql" {
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
    name         = "synchronous_commit"
    value        = "ON"
    apply_method = "pending-reboot"
  }
}

resource "aws_iam_role" "prd_eu_service" {
  name = "${local.environment}-service"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonOpenSearchServiceFullAccess"
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
          "dms.${local.region}.amazonaws.com"
        ]
      }
    }]
  })

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_iam_role_policy" "prd_eu_service_policy" {
  name = "${local.environment}-services-policies"
  role = aws_iam_role.prd_eu_service.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:ExecuteCommand"
        ],
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Resource = [
          "*"
        ]
      },
      {
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:${local.environment}/*"
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
        }, {
        Effect = "Allow"
        Action = [
          "cloudwatch:*"
        ]
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cassandra:Select",
          "cassandra:Create",
          "cassandra:Modify",
          "cassandra:SelectMultiRegionResource",
          "cassandra:ModifyMultiRegionResource",
          "cassandra:CreateMultiRegionResource"
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
  security_group_id = module.prd_eu_networking.vpc.default_security_group_id
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group_rule" "cloudfront" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  description       = "Allow CloudFront IPs to access the ALB"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group" "alb" {
  name   = "alb"
  vpc_id = module.prd_eu_networking.vpc.id

  tags = {
    Name = "alb"
  }
}

resource "aws_lb" "prd_eu" {
  name               = local.environment
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    module.prd_eu_networking.vpc.default_security_group_id,
    aws_security_group.alb.id
  ]
  subnets = [
    module.prd_eu_networking.subnet_public_1.id,
    module.prd_eu_networking.subnet_public_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  access_logs {
    bucket  = "alb-revengegames-prd-eu"
    prefix  = "access-logs/prod"
    enabled = true
  }

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.prd_eu.arn
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

data "cloudflare_zone" "root" {
  name = local.root_domain
}

data "cloudflare_zone" "hacksaw" {
  name = local.hacksaw_domain
}

data "cloudflare_zone" "pgs" {
  name = local.pgs_dns
}
###############
### alb private
###############
resource "aws_lb" "prd_eu_private" {
  name               = "${local.environment}-lambda"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.prd_eu_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.prd_eu_networking.subnet_private_1.id,
    module.prd_eu_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private" {
  load_balancer_arn = aws_lb.prd_eu_private.arn
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
  depends_on = [aws_lb.prd_eu_private]
}

resource "aws_dynamodb_table" "prd_eu_player_attributes" {
  name         = "${local.environment}_player_attributes"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "Id"

  attribute {
    name = "Id"
    type = "S"
  }

  # Optional: Tags
  tags = {
    Environment = "${local.environment}"
  }
}


### alb private 2
resource "aws_lb" "prd_eu_private2" {
  name               = "${local.environment}-lambda-2"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.prd_eu_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.prd_eu_networking.subnet_private_1.id,
    module.prd_eu_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private2" {
  load_balancer_arn = aws_lb.prd_eu_private2.arn
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
  depends_on = [aws_lb.prd_eu_private2]
}



###############
### alb private3
###############
resource "aws_lb" "prd_eu_private3" {
  name               = "${local.environment}-lambda-3"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.prd_eu_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.prd_eu_networking.subnet_private_1.id,
    module.prd_eu_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private3" {
  load_balancer_arn = aws_lb.prd_eu_private3.arn
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
  depends_on = [aws_lb.prd_eu_private3]
}



###############
### alb private4
###############
resource "aws_lb" "prd_eu_private4" {
  name               = "${local.environment}-lambda-4"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.prd_eu_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.prd_eu_networking.subnet_private_1.id,
    module.prd_eu_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private4" {
  load_balancer_arn = aws_lb.prd_eu_private4.arn
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
  depends_on = [aws_lb.prd_eu_private4]
}


###############
### alb private5
###############
resource "aws_lb" "prd_eu_private5" {
  name               = "${local.environment}-lambda-5"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.prd_eu_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.prd_eu_networking.subnet_private_1.id,
    module.prd_eu_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private5" {
  load_balancer_arn = aws_lb.prd_eu_private5.arn
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
  depends_on = [aws_lb.prd_eu_private5]
}