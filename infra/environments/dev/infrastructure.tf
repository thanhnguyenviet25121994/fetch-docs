locals {
  project          = "revengegames"
  environment      = "dev"
  region           = "ap-southeast-1"
  vpc_cidr_block   = "10.0.0.0/16"
  root_domain      = "revenge-games.com"
  dev_root_domain  = "dev.revenge-games.com"
  aws_account_id   = "211125478834"
  allstar_domain   = "all-star.games"
  rectangle_domain = "rectangle-games.com"
}

module "dev_networking" {
  source = "../../modules/networking"
  providers = {
    aws = aws.current
  }
  app_env    = local.environment
  cidr_block = local.vpc_cidr_block
}

# TODO: extract to db module
resource "aws_db_subnet_group" "this" {
  name_prefix = "${local.environment}-"
  subnet_ids = [
    module.dev_networking.subnet_private_1.id,
    module.dev_networking.subnet_private_2.id
  ]

  tags = {
    Environment = "${local.environment}"
  }
}

# Required for DMS
resource "aws_rds_cluster_parameter_group" "prod_rds_postgresql" {
  name        = local.environment
  family      = "aurora-postgresql15"
  description = "dev"

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

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_rds_cluster" "dev_main" {
  cluster_identifier_prefix = "${local.environment}-"

  engine         = "aurora-postgresql"
  engine_mode    = "provisioned"
  engine_version = "15" # Required as DMS only support v15

  db_subnet_group_name = aws_db_subnet_group.this.name

  master_username             = "sqladmin"
  manage_master_user_password = true

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.prod_rds_postgresql.name

  backup_retention_period         = 7
  enabled_cloudwatch_logs_exports = ["postgresql"]
  skip_final_snapshot             = true

  serverlessv2_scaling_configuration {
    max_capacity = 16.0
    min_capacity = 0.5
  }

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_rds_cluster_instance" "dev_main_primary" {
  cluster_identifier = aws_rds_cluster.dev_main.id

  identifier_prefix = "${local.environment}-"
  instance_class    = "db.serverless"

  engine         = aws_rds_cluster.dev_main.engine
  engine_version = aws_rds_cluster.dev_main.engine_version

  performance_insights_enabled = true

  tags = {
    Environment = "${local.environment}"
  }
}

# resource "aws_rds_cluster_instance" "dev_main_reader" {
#   cluster_identifier = aws_rds_cluster.dev_main.id

#   identifier_prefix = "${local.environment}-reader"
#   instance_class    = "db.serverless"

#   engine         = aws_rds_cluster.dev_main.engine
#   engine_version = aws_rds_cluster.dev_main.engine_version

#   performance_insights_enabled = true

#   tags = {
#     Environment = "${local.environment}"
#   }
# }

resource "aws_iam_role" "dev_service" {
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
          "export.rds.amazonaws.com"
        ]
      }
    }]
  })

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_iam_role_policy" "dev_service_policy" {
  name = "${local.environment}-services-policies"
  role = aws_iam_role.dev_service.id

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
          "arn:aws:secretsmanager:*:*:secret:${local.environment}/*",
          "arn:aws:secretsmanager:ap-southeast-1:211125478834:secret:rds!cluster-c6df2a12-a195-4104-99d5-a49b0fa0a96e-ZRmc2p"
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
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::revengegames-dev",
          "arn:aws:s3:::revengegames-dev/*",
          "arn:aws:s3:::dev-player-retention-2",
          "arn:aws:s3:::dev-player-retention-2/*"
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
          "arn:aws:lambda:*:*:function:dev-logic-*"
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
      }
    ]
  })
}

module "security_group" {
  source = "../../modules/security-group"
  vpc_id = module.dev_networking.vpc.id
  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_security_group" "alb" {
  name   = "${local.environment}-alb-sg"
  vpc_id = module.dev_networking.vpc.id
  tags = {
    Name = "${local.environment}-alb-sg"
  }
  ingress {
    description = "Allow other resources in VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "dev" {
  name               = local.environment
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.alb.id,
    module.security_group.cloudflare_sg_id,
    module.security_group.cloudfront_sg_id
  ]
  subnets = [
    module.dev_networking.subnet_public_1.id,
    module.dev_networking.subnet_public_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  access_logs {
    enabled = true
    bucket  = "revengegames-alb-dev"
    prefix  = "access-logs"
  }

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.dev.arn
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


resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.dev.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-0-2021-06"
  certificate_arn   = "arn:aws:acm:ap-southeast-1:211125478834:certificate/e0890b97-82a7-429e-ac3b-c319c7513542"
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
resource "aws_lb" "dev_private" {
  name               = "${local.environment}-lambda"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.dev_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.dev_networking.subnet_private_1.id,
    module.dev_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private" {
  load_balancer_arn = aws_lb.dev_private.arn
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
  depends_on = [aws_lb.dev_private]
}




###############
### alb private2
###############
resource "aws_lb" "dev_private2" {
  name               = "${local.environment}-lambda-2"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.dev_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.dev_networking.subnet_private_1.id,
    module.dev_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private2" {
  load_balancer_arn = aws_lb.dev_private2.arn
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
  depends_on = [aws_lb.dev_private2]
}


###############
### alb private3
###############
resource "aws_lb" "dev_private3" {
  name               = "${local.environment}-lambda-3"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.dev_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.dev_networking.subnet_private_1.id,
    module.dev_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private3" {
  load_balancer_arn = aws_lb.dev_private3.arn
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
  depends_on = [aws_lb.dev_private3]
}


###############
### alb private4
###############
resource "aws_lb" "dev_private4" {
  name               = "${local.environment}-lambda-4"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.dev_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.dev_networking.subnet_private_1.id,
    module.dev_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private4" {
  load_balancer_arn = aws_lb.dev_private4.arn
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
  depends_on = [aws_lb.dev_private4]
}



###############
### alb private5
###############
resource "aws_lb" "dev_private5" {
  name               = "${local.environment}-lambda-5"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.dev_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.dev_networking.subnet_private_1.id,
    module.dev_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private5" {
  load_balancer_arn = aws_lb.dev_private5.arn
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
  depends_on = [aws_lb.dev_private5]
}






locals {
  lambda_albs = {
    lambda-6 = {
      internal = true
      subnets = [
        module.dev_networking.subnet_private_1.id,
        module.dev_networking.subnet_private_2.id
      ]
    }
    # lambda-7 = {
    #   internal = true
    #   subnets = [
    #     module.dev_networking.subnet_private_3.id,
    #     module.dev_networking.subnet_private_4.id
    #   ]
    # }
  }
}

resource "aws_lb" "lambda_private" {
  for_each = local.lambda_albs

  name               = "${local.environment}-${each.key}"
  internal           = each.value.internal
  load_balancer_type = "application"
  security_groups    = [module.dev_networking.vpc.default_security_group_id]
  subnets            = each.value.subnets

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = local.environment
  }
}

resource "aws_lb_listener" "lambda_private" {
  for_each = aws_lb.lambda_private

  load_balancer_arn = each.value.arn
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
