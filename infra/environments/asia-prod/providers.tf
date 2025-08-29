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
    key            = "devops/infrastructure-asia-prod.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "rg-tf-state-lock-prod-asia"

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
  alias  = "global"
  region = "us-east-1"
}

provider "cloudflare" {
  api_token = "9Mg0rWpd7zKw5CyNGhF3SS2Ay9Z-ToZpRGOuK_BG"
}
