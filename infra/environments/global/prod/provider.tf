provider "aws" {
  region = local.aws_region

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  default_tags {
    tags = {
      ProjectName = "${local.project_name}"
      Terraform   = true
    }
  }
}

provider "aws" {
  region = "us-east-1" # CloudFront expects ACM resources in us-east-1 region only
  alias  = "us-e-1"

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
  skip_requesting_account_id = false
}

provider "aws" {
  region = "ap-southeast-1" # VPN
  alias  = "ap-s-1"

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
  skip_requesting_account_id = false
}


terraform {
  #   required_providers {
  #     cloudflare = {
  #       source  = "cloudflare/cloudflare"
  #       version = "~> 4.0"
  #     }
  #   }
  backend "s3" {
    bucket         = "revengegames"                    # Replace with your S3 bucket name
    key            = "devops/global/terraform.tfstate" # Replace with the desired state file path (e.g., "prod/terraform.tfstate")
    region         = "ap-southeast-1"                  # The region where your S3 bucket is located
    dynamodb_table = "rg-tf-state-lock-global"         # DynamoDB table for state locking (optional but recommended)
    encrypt        = true                              # Enable server-side encryption for the state file
  }
}

