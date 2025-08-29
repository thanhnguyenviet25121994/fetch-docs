module "config_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v4.11.0"

  bucket        = "${local.project}-${local.environment}-config"
  force_destroy = true
}