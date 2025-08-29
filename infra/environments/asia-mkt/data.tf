data "terraform_remote_state" "mkt_eu" {
  backend = "s3"

  config = {
    bucket = "revengegames"
    key    = "devops/infrastructure-eu-mkt.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "mkt" {
  backend = "s3"

  config = {
    bucket = "revengegames"
    key    = "devops/infrastructure-mkt.tfstate"
    region = "ap-southeast-1"
  }
}