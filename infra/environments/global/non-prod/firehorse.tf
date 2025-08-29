# resource "aws_kinesis_firehose_delivery_stream" "log_delivery_stream" {
#   name        = "revengegames-log-delivery-stream"
#   destination = "extended_s3"

#   extended_s3_configuration {
#     role_arn           = module.firehose_role.iam_role_arn
#     bucket_arn         = module.bucket_firehose.s3_bucket_arn
#     buffering_size     = 5
#     buffering_interval = 300
#     compression_format = "GZIP"
#     file_extension = ".log"
#     prefix              = "firehose-data/!{timestamp:yyyy}/!{timestamp:MM}/!{timestamp:dd}/"
#     error_output_prefix = "firehose-errors/!{firehose:error-output-type}/!{timestamp:yyyy}/!{timestamp:MM}/!{timestamp:dd}/"
#     cloudwatch_logging_options {
#       enabled         = true
#       log_group_name  = "/aws/kinesisfirehose/revengegames-log-delivery-stream"
#       log_stream_name = "S3Delivery"
#     }
#   }
# }