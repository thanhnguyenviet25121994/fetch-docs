locals {
  environment     = "mkt"
  region          = "sa-east-1"
  vpc_cidr_block  = "10.20.0.0/16"
  root_domain     = "rg-lgna.com"
  pgs_domain      = "1adz83lbv.com"
  hacksaw_domain  = "hacksawproduction.com"
  available_zones = ["sa-east-1a", "sa-east-1c"]
}

provider "aws" {
  region = local.region
}

module "mkt_networking" {
  source = "../../modules/networking"
  providers = {
    aws = aws.current
  }
  app_env         = local.environment
  cidr_block      = local.vpc_cidr_block
  available_zones = local.available_zones
}

# # TODO: extract to db module
resource "aws_db_subnet_group" "this" {
  name_prefix = "${local.environment}-"
  subnet_ids = [
    module.mkt_networking.subnet_private_1.id,
    module.mkt_networking.subnet_private_2.id
  ]

  tags = {
    Environment = "${local.environment}"
  }
}

# # Required for DMS
resource "aws_rds_cluster_parameter_group" "mkt_rds_postgresql" {
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

resource "aws_rds_cluster" "mkt_main" {
  cluster_identifier_prefix = "${local.environment}-"

  engine         = "aurora-postgresql"
  engine_mode    = "provisioned"
  engine_version = "15" # Required as DMS only support v15

  db_subnet_group_name = aws_db_subnet_group.this.name

  master_username             = "sqladmin"
  manage_master_user_password = true

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.mkt_rds_postgresql.name

  backup_retention_period         = 30
  enabled_cloudwatch_logs_exports = ["postgresql"]
  skip_final_snapshot             = true

  serverlessv2_scaling_configuration {
    max_capacity = 8
    min_capacity = 0.5
  }

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_rds_cluster_instance" "mkt_main_primary" {
  cluster_identifier = aws_rds_cluster.mkt_main.id

  identifier_prefix = "${local.environment}-"
  instance_class    = "db.serverless"

  engine         = aws_rds_cluster.mkt_main.engine
  engine_version = aws_rds_cluster.mkt_main.engine_version

  performance_insights_enabled = true

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_iam_role" "mkt_service" {
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

resource "aws_iam_role_policy" "mkt_service_policy" {
  name = "${local.environment}-services-policies"
  role = aws_iam_role.mkt_service.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "secretsmanager:GetSecretValue",
      ]
      Effect = "Allow"
      Resource = [
        "arn:aws:secretsmanager:*:*:secret:${local.environment}/*",
        aws_rds_cluster.mkt_main.master_user_secret[0].secret_arn
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
        "logs:TagLogGroup",
        "es:*"
      ]
      Effect = "Allow"
      Resource = [
        "arn:aws:logs:*:*:log-group:${local.environment}-*",
        "arn:aws:logs:*:*:log-group:dms-tasks-${local.environment}-*",
        "arn:aws:es:*:*:domain/mkt-opensearch/*"
      ]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:GetFunction",
          "lambda:InvokeFunction"
        ]
        Resource = [
          "arn:aws:lambda:*:*:function:mkt-logic-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cassandra:Select",
          "cassandra:Create",
          "cassandra:Modify",
          "cassandra:SelectMultiRegionResource",
          "cassandra:ModifyMultiRegionResource"
        ]
        Resource = [
          "*"
        ]
    }]
  })
}

resource "aws_lb" "mkt" {
  name               = local.environment
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    module.mkt_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.mkt_networking.subnet_public_1.id,
    module.mkt_networking.subnet_public_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  access_logs {
    enabled = true
    bucket  = "alb-revengegames-prod"
    prefix  = "alb-mkt"
  }

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.mkt.arn
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

resource "aws_service_discovery_http_namespace" "mkt" {
  name = local.environment
}

data "cloudflare_zone" "root" {
  name = local.root_domain
}

data "cloudflare_zone" "hacksaw" {
  name = local.hacksaw_domain
}

data "cloudflare_zone" "pgs" {
  name = local.pgs_domain
}



###############
### alb private
###############
resource "aws_lb" "mkt_private" {
  name               = "${local.environment}-lambda"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.mkt_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.mkt_networking.subnet_private_1.id,
    module.mkt_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private" {
  load_balancer_arn = aws_lb.mkt_private.arn
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
  depends_on = [aws_lb.mkt_private]
}



resource "aws_dynamodb_table" "mkt_player_attributes" {
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
resource "aws_lb" "mkt_private2" {
  name               = "${local.environment}-lambda-2"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.mkt_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.mkt_networking.subnet_private_1.id,
    module.mkt_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private2" {
  load_balancer_arn = aws_lb.mkt_private2.arn
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
  depends_on = [aws_lb.mkt_private2]
}




###############
### alb private3
###############
resource "aws_lb" "mkt_private3" {
  name               = "${local.environment}-lambda-3"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.mkt_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.mkt_networking.subnet_private_1.id,
    module.mkt_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private3" {
  load_balancer_arn = aws_lb.mkt_private3.arn
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
  depends_on = [aws_lb.mkt_private3]
}




###############
### alb private4
###############
resource "aws_lb" "mkt_private4" {
  name               = "${local.environment}-lambda-4"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.mkt_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.mkt_networking.subnet_private_1.id,
    module.mkt_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private4" {
  load_balancer_arn = aws_lb.mkt_private4.arn
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
  depends_on = [aws_lb.mkt_private4]
}


###############
### alb private4
###############
resource "aws_lb" "mkt_private5" {
  name               = "${local.environment}-lambda-5"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.mkt_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.mkt_networking.subnet_private_1.id,
    module.mkt_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private5" {
  load_balancer_arn = aws_lb.mkt_private5.arn
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
  depends_on = [aws_lb.mkt_private5]
}