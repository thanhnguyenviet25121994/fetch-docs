terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.80.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "revengegames"
    key            = "devops/infrastructure-staging.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "rg-tf-state-lock-staging"

  }
}
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
provider "aws" {
  alias  = "current"
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Project_Name = "${local.project}"
      Environment  = "${local.environment}"
      Terraform    = true
    }
  }
}


provider "aws" {
  alias  = "us-e-1"
  region = "us-east-1"
}


provider "cloudflare" {
  # api_token = "eONzgYKCbltIMzhJoXOgBoy6dE5AKS_1IdAZ5UbL"
  api_token = "r_IvcEen-qkb8FaTGsDIvHIi_u9X2AOp18gmiE_F"

}