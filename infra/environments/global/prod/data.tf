data "terraform_remote_state" "dev" {
  backend = "s3"

  config = {
    bucket = "revengegames"
    key    = "devops/infrastructure"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "staging" {
  backend = "s3"

  config = {
    bucket = "revengegames"
    key    = "devops/infrastructure-staging.tfstate"
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


data "terraform_remote_state" "mkt" {
  backend = "s3"

  config = {
    bucket = "revengegames"
    key    = "devops/infrastructure-mkt.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "prd_eu" {
  backend = "s3"

  config = {
    bucket = "revengegames"
    key    = "devops/infrastructure-eu-prod.tfstate"
    region = "ap-southeast-1"
  }
}

data "terraform_remote_state" "mkt_eu" {
  backend = "s3"

  config = {
    bucket = "revengegames"
    key    = "devops/infrastructure-eu-mkt.tfstate"
    region = "ap-southeast-1"
  }
}



