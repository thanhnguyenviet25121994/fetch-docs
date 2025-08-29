locals {
  project_name   = "RG"
  prefix         = "revengegames"
  aws_account_id = "615299744176"
  aws_region     = "ap-southeast-1"
  domain         = "revenge.games"

  ############
  ## IAM
  ############
  policy_file                 = "${abspath("${path.module}/templates/iam")}/cicd.json.tftpl"
  PermissionsForCWL_file      = "${abspath("${path.module}/templates/iam")}/PermissionsForCWL.json.tftpl"
  PermissionsForFirehose_file = "${abspath("${path.module}/templates/iam")}/PermissionsForFirehose.json.tftpl"
  PermissionsForCWL_FH_file   = "${abspath("${path.module}/templates/iam")}/PermissionsForCWL_FH.json.tftpl"

}