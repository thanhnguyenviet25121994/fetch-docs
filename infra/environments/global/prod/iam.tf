resource "aws_iam_policy" "invoke_lambda" {
  name        = "ip.dev-invole-lambda"
  description = "A policy dev-invole-lambda"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowListLambdaFunctions"
        Effect = "Allow"
        Action = [
          "lambda:ListFunctions",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "ap-southeast-1"
          }
        }
      },
      {
        Sid      = "AllowInvokeLambdaFunctions"
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = "arn:aws:lambda:ap-southeast-1:${local.aws_account_id}:function:dev-*"
      }
    ]
  })
}



resource "aws_iam_policy" "iam_self_management" {
  name   = "ip.dev-manage-accesskey"
  policy = data.aws_iam_policy_document.iam_self_management.json

}


#######
## policy for portal operator team
data "aws_iam_policy_document" "portal_operator_policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "ssm:SendCommand",
      "ssm:GetCommandInvocation",
      "ssm:StartSession",
      "ssm:DescribeInstanceInformation",
      "ssm:DescribeSessions",
      "ssm:TerminateSession"
    ]
    resources = [
      "arn:aws:ec2:ap-southeast-1:211125478834:instance/i-0a7f05a474d30f822",
      "arn:aws:ssm:ap-southeast-1:211125478834:document/AWS-StartSSHSession",
      "arn:aws:ssm:ap-southeast-1:211125478834:document/AWS-StartPortForwardingSession",
      "arn:aws:ssm:ap-southeast-1:211125478834:document/SSM-SessionManagerRunShell",
      "arn:aws:ssm:ap-southeast-1::document/AWS-StartPortForwardingSessionToRemoteHost"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = ["ap-southeast-1", "ap-northeast-1"]
    }
  }

}

# Create the IAM policy
resource "aws_iam_policy" "portal_operator_policy" {
  name        = "ip.PortalOperatorSSM"
  description = "PortalOperatorSSM policy"
  policy      = data.aws_iam_policy_document.portal_operator_policy.json
}