output "hung_pass" {
  value     = module.iam_hungvu.iam_user_login_profile_password
  sensitive = true
}

# output "firehose_arn" {
#   value = aws_kinesis_firehose_delivery_stream.log_delivery_stream.arn
# }

# output "cloudwatch_log_destination_firehose" {
#   value = aws_cloudwatch_log_destination.firehose_cwd.arn
# }

output "cloudwatch_log_destination_kinesis" {
  value = aws_cloudwatch_log_destination.this.arn
}