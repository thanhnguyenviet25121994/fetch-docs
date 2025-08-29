locals {
  project_name   = "RG"
  aws_account_id = "211125478834"
  aws_region     = "ap-southeast-1"
  domain         = "revenge.games"

  ############
  ## IAM
  ############
  policy_file = "${abspath("${path.module}/templates/iam")}/cicd.json.tftpl"

}