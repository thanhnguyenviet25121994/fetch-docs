resource "aws_kinesis_stream" "log_stream" {
  name             = "LogCentralizedRecipientStream"
  shard_count      = 0
  retention_period = 168


  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = {
    Environment = "prod"
    Title       = "logging"
  }
}

resource "aws_kinesis_stream" "prod_log_stream" {
  name             = "PROD-LogCentralizedRecipientStream"
  shard_count      = 0
  retention_period = 24


  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = {
    Environment = "prod"
    Title       = "logging"
  }
}