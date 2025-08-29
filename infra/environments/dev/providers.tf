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
  backend "s3" {
    bucket         = "revengegames"
    key            = "devops/infrastructure"
    region         = "ap-southeast-1"
    dynamodb_table = "rg-tf-state-lock-dev"
  }
}

provider "aws" {
  alias  = "current"
  region = "ap-southeast-1"
  default_tags {
    tags = {
      Project_Name = "${local.project}"
      Environment  = "${local.environment}"
      Terraform    = true
    }
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}


provider "aws" {
  alias  = "sa-east-1"
  region = "sa-east-1"
}


provider "cloudflare" {
  api_token = "eONzgYKCbltIMzhJoXOgBoy6dE5AKS_1IdAZ5UbL"
}