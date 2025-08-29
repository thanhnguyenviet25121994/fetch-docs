data "aws_iam_policy" "admin" {
  name = "AdministratorAccess"
}

data "aws_iam_policy_document" "cwl_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:logs:ap-southeast-1:211125478834:*",
        "arn:aws:logs:eu-west-1:211125478834:*",
        "arn:aws:logs:sa-east-1:211125478834:*",
        "arn:aws:logs:ap-southeast-1:615299744176:*"
      ]
    }
  }
}

data "aws_iam_policy_document" "cw_destination_policy" {
  version = "2012-10-17"

  statement {
    sid    = ""
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["211125478834"]
    }

    actions = ["logs:PutSubscriptionFilter", "logs:PutAccountPolicy"]
    resources = [
      "${aws_cloudwatch_log_destination.this.arn}"
    ]

  }
}




# data "aws_iam_policy_document" "firehose_assume_role_policy" {
#   statement {
#     effect = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["firehose.amazonaws.com"]
#     }
#     actions = ["sts:AssumeRole"]
#     condition {
#       test     = "StringEquals"
#       variable = "sts:ExternalId"
#       values   = ["615299744176"]
#     }
#   }
# }


# data "aws_iam_policy_document" "assume_role_cwl_policy" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["logs.ap-southeast-1.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]

#     condition {
#       test     = "StringLike"
#       variable = "aws:SourceArn"
#       values = [
#         "arn:aws:logs:ap-southeast-1:211125478834:*",
#         "arn:aws:logs:ap-southeast-1:615299744176:*"
#       ]
#     }
#   }
# }



# data "aws_iam_policy_document" "cw_fh_destination_policy" {
#   version = "2012-10-17"

#   statement {
#     sid    = ""
#     effect = "Allow"

#     principals {
#       type        = "AWS"
#       identifiers = ["211125478834"]
#     }

#     actions   = ["logs:PutSubscriptionFilter"]
#     resources = ["${aws_cloudwatch_log_destination.firehose_cwd.arn}"]
#   }
# }