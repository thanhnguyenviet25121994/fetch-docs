data "terraform_remote_state" "prod_eu" {
  backend = "s3"

  config = {
    bucket = "revengegames"
    key    = "devops/infrastructure-eu-prod.tfstate"
    region = "ap-southeast-1"
  }
}


data "terraform_remote_state" "prod" {
  backend = "s3"

  config = {
    bucket = "revengegames"
    key    = "devops/infrastructure-prod.tfstate"
    region = "ap-southeast-1"
  }
}