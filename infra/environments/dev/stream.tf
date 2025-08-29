resource "aws_s3_bucket" "dev_firehouse_bucket" {
  bucket = "dev-firehose-delivery-bucket"
}
resource "aws_iam_role" "firehose_role" {
  name = "firehose_delivery_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "firehose.amazonaws.com"
      }
    }]
  })
}

# Attach policies to the IAM role
resource "aws_iam_role_policy" "firehose_policy" {
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:ListStreams"
        ],
        Resource = "arn:aws:kinesis:ap-southeast-1:211125478834:stream/dev_bet_result_2__kinesis"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ],
        Resource = [
          "${aws_s3_bucket.dev_firehouse_bucket.arn}",
          "${aws_s3_bucket.dev_firehouse_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_kinesis_firehose_delivery_stream" "dev" {
  name        = "${local.environment}-firehose-stream"
  destination = "http_endpoint"

  kinesis_source_configuration {
    kinesis_stream_arn = "arn:aws:kinesis:ap-southeast-1:211125478834:stream/dev_bet_result_2__kinesis"
    role_arn           = aws_iam_role.firehose_role.arn
  }

  http_endpoint_configuration {
    url                = "https://api-stream.sandbox.revenge-games.com/api/bet_result"
    name               = "dev test firehose"
    buffering_size     = 7
    buffering_interval = 60
    role_arn           = aws_iam_role.firehose_role.arn
    s3_backup_mode     = "FailedDataOnly"

    secrets_manager_configuration {
      secret_arn = "arn:aws:secretsmanager:ap-southeast-1:211125478834:secret:consumer/firehose-E3bDYQ"
      role_arn   = aws_iam_role.firehose_role.arn

    }

    s3_configuration {
      role_arn           = aws_iam_role.firehose_role.arn
      bucket_arn         = aws_s3_bucket.dev_firehouse_bucket.arn
      buffering_size     = 100
      buffering_interval = 60
      compression_format = "UNCOMPRESSED"
    }

    request_configuration {
      content_encoding = "GZIP"

      #   common_attributes {
      #     name  = "testname"
      #     value = "testvalue"
      #   }

      #   common_attributes {
      #     name  = "testname2"
      #     value = "testvalue2"
      #   }
    }
  }
}


resource "aws_kinesis_stream" "dev_stream" {
  name             = "dev_bet_result_2__kinesis"
  shard_count      = 0
  retention_period = 24


  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = {
    Environment = "dev"
  }
}



resource "aws_kinesis_stream" "dev_transfer_stream" {
  name             = "dev_transfer_result_2__kinesis"
  shard_count      = 0
  retention_period = 24


  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = {
    Environment = "dev"
  }
}