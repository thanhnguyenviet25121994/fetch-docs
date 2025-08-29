module "cicd_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "v5.33.0"

  role_name         = "ir.cicd-deploy-non-prod"
  role_description  = "Roles for cicd assume}"
  create_role       = true
  role_requires_mfa = false
  trusted_role_arns = [
    "arn:aws:iam::211125478834:root",
  ]
  custom_role_policy_arns = [

  ]
}

resource "aws_iam_role_policy" "cicd" {
  name = "ip.cicd-deploy-non-prod"
  role = module.cicd_role.iam_role_name
  # policy = data.template_file.inline.rendered
  policy = templatefile(local.policy_file, {})
}


module "cwl_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "v5.58.0"

  role_name                       = "ir.CWLtoKinesisRole"
  role_description                = "Roles for CWL to kinesis cross account"
  create_role                     = true
  role_requires_mfa               = false
  create_custom_role_trust_policy = true
  custom_role_trust_policy        = data.aws_iam_policy_document.cwl_policy.json
}

resource "aws_iam_role_policy" "cwl_kinesis" {
  name = "ip.PermissionsForCWL"
  role = module.cwl_role.iam_role_name
  # policy = data.template_file.inline.rendered
  policy = templatefile(local.PermissionsForCWL_file, {
    kinesis1 = aws_kinesis_stream.log_stream.arn,
    kinesis2 = aws_kinesis_stream.prod_log_stream.arn
  })
}


# module "firehose_role" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
#   version = "v5.58.0"

#   role_name                       = "ir.FirehosetoS3Role"
#   role_description                = "Roles for CWL to kinesis cross account"
#   create_role                     = true
#   role_requires_mfa               = false
#   create_custom_role_trust_policy = true
#   custom_role_trust_policy        = data.aws_iam_policy_document.firehose_assume_role_policy.json
# }


# resource "aws_iam_role_policy" "firehose_s3" {
#   name = "ip.FirehosetoS3Role"
#   role = module.firehose_role.iam_role_name
#   # policy = data.template_file.inline.rendered
#   policy = templatefile(local.PermissionsForFirehose_file, {
#     bucket_name = module.bucket_firehose.s3_bucket_id
#   })
# }



# module "cwl_firehose_role" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
#   version = "v5.58.0"

#   role_name                       = "ir.CWLtoKinesisFirehoseRole"
#   role_description                = "Roles for CWL to kinesis cross account"
#   create_role                     = true
#   role_requires_mfa               = false
#   create_custom_role_trust_policy = true
#   custom_role_trust_policy        = data.aws_iam_policy_document.assume_role_cwl_policy.json
# }


# resource "aws_iam_role_policy" "firehose_cwl" {
#   name = "ip.PermissionsForCWL_FH_file"
#   role = module.cwl_firehose_role.iam_role_name
#   # policy = data.template_file.inline.rendered
#   policy = templatefile(local.PermissionsForCWL_FH_file, {

#   })
# }