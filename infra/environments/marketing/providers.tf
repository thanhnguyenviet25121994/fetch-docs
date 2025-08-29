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
    bucket = "revengegames"
    key    = "devops/infrastructure-mkt.tfstate"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  alias  = "current"
  region = "sa-east-1"
}

provider "cloudflare" {
  api_token = "9Mg0rWpd7zKw5CyNGhF3SS2Ay9Z-ToZpRGOuK_BG"

}
