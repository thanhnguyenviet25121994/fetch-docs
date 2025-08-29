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

  skip_requesting_account_id = false
}


terraform {
  backend "s3" {
    bucket       = "revengegames-tfstate"     # Replace with your S3 bucket name
    key          = "global/terraform.tfstate" # Replace with the desired state file path (e.g., "prod/terraform.tfstate")
    region       = "ap-southeast-1"           # The region where your S3 bucket is located
    use_lockfile = true
  }
}


provider "aws" {
  alias  = "sa_east_1"
  region = "sa-east-1"
}