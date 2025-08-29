locals {
  environment     = "prod"
  region          = "sa-east-1"
  vpc_cidr_block  = "10.20.0.0/16"
  root_domain     = "rg-lgna.com"
  revenge_domain  = "revenge-games.com"
  project         = "revengegames"
  pp_domain       = "pragmaticpplay.com"
  aw_domain       = "acewin-gaming.com"
  available_zones = ["sa-east-1a", "sa-east-1c"]
}

provider "aws" {
  region = local.region
}

module "prod_networking" {
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
    module.prod_networking.subnet_private_1.id,
    module.prod_networking.subnet_private_2.id
  ]

  tags = {
    Environment = "${local.environment}"
  }
}

# Required for DMS
resource "aws_rds_cluster_parameter_group" "prod_rds_postgresql" {
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

resource "aws_rds_cluster" "prod_main" {
  cluster_identifier_prefix = "${local.environment}-"

  engine         = "aurora-postgresql"
  engine_mode    = "provisioned"
  engine_version = "15" # Required as DMS only support v15

  db_subnet_group_name = aws_db_subnet_group.this.name

  master_username             = "sqladmin"
  manage_master_user_password = true

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.prod_rds_postgresql.name

  backup_retention_period         = 30
  enabled_cloudwatch_logs_exports = ["postgresql"]
  skip_final_snapshot             = true

  serverlessv2_scaling_configuration {
    max_capacity = 24
    min_capacity = 1
  }

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_rds_cluster_instance" "prod_main_primary" {
  cluster_identifier = aws_rds_cluster.prod_main.id

  identifier_prefix = "${local.environment}-"
  instance_class    = "db.serverless"

  engine         = aws_rds_cluster.prod_main.engine
  engine_version = aws_rds_cluster.prod_main.engine_version

  performance_insights_enabled = true

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_rds_cluster_instance" "prod_main_reader" {
  cluster_identifier = aws_rds_cluster.prod_main.id

  identifier_prefix = "${local.environment}-reader-"
  instance_class    = "db.serverless"

  engine         = aws_rds_cluster.prod_main.engine
  engine_version = aws_rds_cluster.prod_main.engine_version

  performance_insights_enabled = true

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_iam_role" "prod_service" {
  name = "${local.environment}-service"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonOpenSearchServiceFullAccess",
    "arn:aws:iam::aws:policy/AmazonKeyspacesFullAccess"
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

resource "aws_iam_role_policy" "prod_service_policy" {
  name = "${local.environment}-services-policies"
  role = aws_iam_role.prod_service.id

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
        }, {
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:${local.environment}/*",
          aws_rds_cluster.prod_main.master_user_secret[0].secret_arn
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
          "cloudwatch:*",
          "ses:SendEmail"

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
          "arn:aws:lambda:*:*:function:prod-logic-*"
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

resource "aws_lb" "prod" {
  name               = local.environment
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    module.prod_networking.vpc.default_security_group_id,
    aws_security_group.allow_cloudfront_http.id
  ]
  subnets = [
    module.prod_networking.subnet_public_1.id,
    module.prod_networking.subnet_public_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  access_logs {
    bucket  = "alb-revengegames-prod"
    prefix  = "access-logs/prod"
    enabled = true
  }

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.prod.arn
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


resource "aws_security_group" "allow_cloudfront_http" {
  name        = "allow-cloudfront-http"
  vpc_id      = module.prod_networking.vpc.id
  description = "Allow HTTP traffic from CloudFront distribution"

  # Allow inbound HTTP traffic from CloudFront IP ranges
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = ["pl-5da64334"]
  }

  # Optional: Allow outbound traffic to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
  security_group_id = module.prod_networking.vpc.default_security_group_id
}

data "cloudflare_zone" "root" {
  name = local.root_domain
}



###############
### alb private
###############
resource "aws_lb" "prod_private" {
  name               = "${local.environment}-lambda"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.prod_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.prod_networking.subnet_private_1.id,
    module.prod_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  access_logs {
    bucket  = "alb-revengegames-prod"
    prefix  = "access-logs/prod-lambda"
    enabled = true
  }

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private" {
  load_balancer_arn = aws_lb.prod_private.arn
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
  depends_on = [aws_lb.prod_private]
}

resource "aws_dynamodb_table" "prod_player_attributes" {
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
resource "aws_lb" "prod_private2" {
  name               = "${local.environment}-lambda-2"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.prod_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.prod_networking.subnet_private_1.id,
    module.prod_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600
  access_logs {
    bucket  = "alb-revengegames-prod"
    prefix  = "access-logs/prod-lambda-2"
    enabled = true
  }

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private2" {
  load_balancer_arn = aws_lb.prod_private2.arn
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
  depends_on = [aws_lb.prod_private2]
}



###############
### alb private3
###############
resource "aws_lb" "prod_private3" {
  name               = "${local.environment}-lambda-3"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.prod_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.prod_networking.subnet_private_1.id,
    module.prod_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private3" {
  load_balancer_arn = aws_lb.prod_private3.arn
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
  depends_on = [aws_lb.prod_private3]
}

###############
### alb private4
###############
resource "aws_lb" "prod_private4" {
  name               = "${local.environment}-lambda-4"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.prod_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.prod_networking.subnet_private_1.id,
    module.prod_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private4" {
  load_balancer_arn = aws_lb.prod_private4.arn
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
  depends_on = [aws_lb.prod_private4]
}


###############
### alb private4
###############
resource "aws_lb" "prod_private5" {
  name               = "${local.environment}-lambda-5"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.prod_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.prod_networking.subnet_private_1.id,
    module.prod_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private5" {
  load_balancer_arn = aws_lb.prod_private5.arn
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
  depends_on = [aws_lb.prod_private5]
}