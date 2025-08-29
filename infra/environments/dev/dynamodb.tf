

module "dynamodb_snapshot_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = "dev-dynamodb-snapshot"
  attach_policy = true
  policy        = data.aws_iam_policy_document.dynamodb_snapshot_bucket_policy.json

  force_destroy = true
}


data "aws_iam_policy_document" "dynamodb_snapshot_bucket_policy" {
  statement {
    sid    = "ExampleStatement"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["AIDATCKAPEWZFW5TJROUF"]
    }

    actions = [
      "s3:AbortMultipartUpload",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      "arn:aws:s3:::dev-dynamodb-snapshot/*"
    ]
  }
}

