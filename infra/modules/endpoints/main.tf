terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

variable "app_env" {
  type = string
}

variable "vpc" {
  type = object({
    id = string
  })
}

variable "subnet_ids" {
  type = list(string)
}


resource "aws_vpc_endpoint" "staging_secretsmanager" {
  vpc_id              = var.vpc.id
  subnet_ids          = var.subnet_ids
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = "com.amazonaws.ap-southeast-1.secretsmanager"

  tags = {
    Environment = var.app_env
    Name        = "${var.app_env}-secretsmanager"
  }
}

resource "aws_vpc_endpoint" "staging_ecrapi" {
  vpc_id              = var.vpc.id
  subnet_ids          = var.subnet_ids
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = "com.amazonaws.ap-southeast-1.ecr.api"

  tags = {
    Environment = var.app_env
    Name        = "${var.app_env}-ecrapi"
  }
}

resource "aws_vpc_endpoint" "staging_ecrdkr" {
  vpc_id              = var.vpc.id
  subnet_ids          = var.subnet_ids
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = "com.amazonaws.ap-southeast-1.ecr.dkr"

  tags = {
    Environment = var.app_env
    Name        = "${var.app_env}-ecrdkr"
  }
}

resource "aws_vpc_endpoint" "staging_cloudwatch" {
  vpc_id              = var.vpc.id
  subnet_ids          = var.subnet_ids
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = "com.amazonaws.ap-southeast-1.logs"

  tags = {
    Environment = var.app_env
    Name        = "${var.app_env}-cloudwatch"
  }
}

resource "aws_vpc_endpoint" "staging_rds" {
  vpc_id              = var.vpc.id
  subnet_ids          = var.subnet_ids
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = "com.amazonaws.ap-southeast-1.rds"

  tags = {
    Environment = var.app_env
    Name        = "${var.app_env}-rds"
  }
}

resource "aws_vpc_endpoint" "staging_s3" {
  vpc_id              = var.vpc.id
  subnet_ids          = var.subnet_ids
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = "com.amazonaws.ap-southeast-1.s3"

  tags = {
    Environment = var.app_env
    Name        = "${var.app_env}-s3"
  }
}

resource "aws_vpc_endpoint" "staging_dynamodb_gw" {
  vpc_id            = var.vpc.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.ap-southeast-1.dynamodb"

  tags = {
    Environment = var.app_env
    Name        = "${var.app_env}-dynamodb-gw"
  }
}

resource "aws_vpc_endpoint" "staging_s3_gw" {
  vpc_id            = var.vpc.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.ap-southeast-1.s3"

  tags = {
    Environment = var.app_env
    Name        = "${var.app_env}-s3-gw"
  }
}
