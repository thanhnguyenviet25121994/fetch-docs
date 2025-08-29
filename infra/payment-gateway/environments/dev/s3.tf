module "transfer_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v4.0.0"

  bucket = "${local.project_name}-${local.environment}-proof-of-tranfser"

  # attach_policy                            = true
  # policy = data.aws_iam_policy_document.bucket_policy.json

  force_destroy = false

  # block_public_acls       = false
  # block_public_policy     = false
  # ignore_public_acls      = false
  # restrict_public_buckets = false
}