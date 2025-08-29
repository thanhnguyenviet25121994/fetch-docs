locals {
  environment     = "mkt-eu"
  region          = "eu-west-1"
  vpc_cidr_block  = "10.80.0.0/16"
  root_domain     = "lnga-rg.com"
  prefix          = "eu"
  project         = "revengegames"
  rg_domain       = "rg-lgna.com"
  available_zones = ["eu-west-1a", "eu-west-1c"]
  pgs_domain      = "pgs.lnga-rg.com"
  pgs_dns         = "1adz83lbv.com"
  hacksaw_domain  = "hacksawproduction.com"
}

provider "aws" {
  region = local.region
}

module "mkt_eu_networking" {
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
    module.mkt_eu_networking.subnet_private_1.id,
    module.mkt_eu_networking.subnet_private_2.id
  ]

  tags = {
    Environment = "${local.environment}"
  }
}


# Required for DMS
resource "aws_rds_cluster_parameter_group" "mkt_eu_rds_postgresql" {
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

resource "aws_rds_cluster" "mkt_eu_main" {
  cluster_identifier_prefix = "${local.environment}-"

  engine         = "aurora-postgresql"
  engine_mode    = "provisioned"
  engine_version = "15" # Required as DMS only support v15

  db_subnet_group_name = aws_db_subnet_group.this.name

  master_username             = "sqladmin"
  manage_master_user_password = true

  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.mkt_eu_rds_postgresql.name

  backup_retention_period         = 7
  enabled_cloudwatch_logs_exports = ["postgresql"]
  skip_final_snapshot             = true
  vpc_security_group_ids          = [module.rds_sg.security_group_id]

  serverlessv2_scaling_configuration {
    max_capacity = 8
    min_capacity = 0.5
  }

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_rds_cluster_instance" "mkt_eu_main_primary" {
  cluster_identifier = aws_rds_cluster.mkt_eu_main.id

  identifier_prefix = "${local.environment}-"
  instance_class    = "db.serverless"

  engine         = aws_rds_cluster.mkt_eu_main.engine
  engine_version = aws_rds_cluster.mkt_eu_main.engine_version

  performance_insights_enabled = true

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_iam_role" "mkt_eu_service" {
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

resource "aws_iam_role_policy" "mkt_eu_service_policy" {
  name = "${local.environment}-services-policies"
  role = aws_iam_role.mkt_eu_service.id

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
          aws_rds_cluster.mkt_eu_main.master_user_secret[0].secret_arn
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
          "cassandra:ModifyMultiRegionResource"
        ]
        Resource = [
          "*"
        ]
    }]
  })
}

resource "aws_security_group" "alb" {
  name   = "alb"
  vpc_id = module.mkt_eu_networking.vpc.id

  tags = {
    Name = "alb"
  }
}

resource "aws_lb" "mkt_eu" {
  name               = local.environment
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    module.mkt_eu_networking.vpc.default_security_group_id,
    aws_security_group.alb.id
  ]
  subnets = [
    module.mkt_eu_networking.subnet_public_1.id,
    module.mkt_eu_networking.subnet_public_2.id
  ]

  enable_deletion_protection = true

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "${local.environment}-lb"
  #   enabled = true
  # }

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.mkt_eu.arn
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
  security_group_id = module.mkt_eu_networking.vpc.default_security_group_id
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

resource "aws_security_group_rule" "vpc" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  description       = "Allow CloudFront IPs to access the ALB"
  cidr_blocks       = [module.mkt_eu_networking.vpc.cidr_block]
  security_group_id = module.mkt_eu_networking.vpc.default_security_group_id
}

resource "aws_security_group_rule" "rds" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  description       = "Allow private subnets to access RDS"
  cidr_blocks       = [module.mkt_eu_networking.vpc.cidr_block]
  security_group_id = module.mkt_eu_networking.vpc.default_security_group_id
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

##############
## alb private
###############
resource "aws_lb" "mkt_eu_private" {
  name               = "${local.environment}-lambda"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.mkt_eu_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.mkt_eu_networking.subnet_private_1.id,
    module.mkt_eu_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private" {
  load_balancer_arn = aws_lb.mkt_eu_private.arn
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
  depends_on = [aws_lb.mkt_eu_private]
}

resource "aws_dynamodb_table" "mkt_eu_player_attributes" {
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
resource "aws_lb" "mkt_eu_private2" {
  name               = "${local.environment}-lambda-2"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.mkt_eu_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.mkt_eu_networking.subnet_private_1.id,
    module.mkt_eu_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private2" {
  load_balancer_arn = aws_lb.mkt_eu_private2.arn
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
  depends_on = [aws_lb.mkt_eu_private2]
}




###############
### alb private3
###############
resource "aws_lb" "mkt_eu_private3" {
  name               = "${local.environment}-lambda-3"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.mkt_eu_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.mkt_eu_networking.subnet_private_1.id,
    module.mkt_eu_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private3" {
  load_balancer_arn = aws_lb.mkt_eu_private3.arn
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
  depends_on = [aws_lb.mkt_eu_private3]
}



###############
### alb private4
###############
resource "aws_lb" "mkt_eu_private4" {
  name               = "${local.environment}-lambda-4"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.mkt_eu_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.mkt_eu_networking.subnet_private_1.id,
    module.mkt_eu_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private4" {
  load_balancer_arn = aws_lb.mkt_eu_private4.arn
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
  depends_on = [aws_lb.mkt_eu_private4]
}



###############
### alb private5
###############
resource "aws_lb" "mkt_eu_private5" {
  name               = "${local.environment}-lambda-5"
  internal           = true
  load_balancer_type = "application"
  security_groups = [
    module.mkt_eu_networking.vpc.default_security_group_id
  ]
  subnets = [
    module.mkt_eu_networking.subnet_private_1.id,
    module.mkt_eu_networking.subnet_private_2.id
  ]

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_lb_listener" "http_private5" {
  load_balancer_arn = aws_lb.mkt_eu_private5.arn
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
  depends_on = [aws_lb.mkt_eu_private]
}