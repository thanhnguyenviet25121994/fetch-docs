resource "aws_kinesis_stream" "prod_stream" {
  name             = "prod_bet_result_stream"
  shard_count      = 0
  retention_period = 24


  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = {
    Environment = "dev"
  }
}