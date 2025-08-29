resource "aws_cloudwatch_log_destination" "this" {
  name       = "LogDestination"
  role_arn   = module.cwl_role.iam_role_arn
  target_arn = aws_kinesis_stream.log_stream.arn
}

resource "aws_cloudwatch_log_destination_policy" "this" {
  destination_name = aws_cloudwatch_log_destination.this.name
  access_policy    = data.aws_iam_policy_document.cw_destination_policy.json
}



# resource "aws_cloudwatch_log_destination" "cwl_kinesis" {
#   region     = "sa-east-1"
#   name       = "ProdLogDestination"
#   role_arn   = module.cwl_role.iam_role_arn
#   target_arn = aws_kinesis_stream.log_stream.arn
# }

# resource "aws_cloudwatch_log_destination_policy" "cwl_kinesis" {
#   region           = "sa-east-1"
#   destination_name = aws_cloudwatch_log_destination.cwl_kinesis.name
#   access_policy    = data.aws_iam_policy_document.cw_destination_policy.json
# }


# resource "aws_cloudwatch_log_destination" "firehose_cwd" {
#   name       = "firehoseLogDestination"
#   role_arn   = module.cwl_firehose_role.iam_role_arn
#   target_arn = aws_kinesis_firehose_delivery_stream.log_delivery_stream.arn
# }

# resource "aws_cloudwatch_log_destination_policy" "firehose_cwd" {
#   destination_name = aws_cloudwatch_log_destination.firehose_cwd.name
#   access_policy    = data.aws_iam_policy_document.cw_fh_destination_policy.json
# }
