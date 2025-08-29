module "bucket_firehose" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "v4.11.0"

  bucket = "revengegames-firehose"

  force_destroy = true
}