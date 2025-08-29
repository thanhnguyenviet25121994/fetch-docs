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
    key            = "devops/infrastructure-prod.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "rg-tf-state-lock-prod"
  }
}

provider "aws" {
  alias  = "current"
  region = "sa-east-1"

  # default_tags {
  #   tags = {
  #     awsApplication = "arn:aws:resource-groups:sa-east-1:211125478834:group/revengegames-prod/01wkc4lnprx31q8ufdxkgy09uc"
  #   }
  # }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "cloudflare" {
  api_token = "9Mg0rWpd7zKw5CyNGhF3SS2Ay9Z-ToZpRGOuK_BG"
}
