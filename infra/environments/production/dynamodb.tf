resource "aws_dynamodb_table" "prod_player_attributes_2" {
  name         = "${local.environment}_player_attributes_2"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "Id"

  attribute {
    name = "Id"
    type = "S"
  }

  # Optional: Tags
  tags = {
    Environment = "${local.environment}"
  }
}

resource "aws_dynamodb_table" "prod_bet_results_2" {
  name     = "${local.environment}_bet_results_2"
  hash_key = "BetId"

  deletion_protection_enabled = true

  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"


  range_key = "created"
  attribute {
    name = "BetId"
    type = "S"
  }

  attribute {
    name = "created"
    type = "S"
  }

  attribute {
    name = "ParentBetId"
    type = "S"
  }

  attribute {
    name = "playerId#gameId"
    type = "S"
  }

  global_secondary_index {
    name               = "playerIdGameIdCreatedIndex"
    hash_key           = "playerId#gameId"
    range_key          = "created"
    projection_type    = "INCLUDE"
    non_key_attributes = ["BetId", "State", "Bet", "Result", "ParentBetId"]
    read_capacity      = 0
    write_capacity     = 0
  }

  global_secondary_index {
    name               = "ParentBetIdIndex"
    hash_key           = "ParentBetId"
    range_key          = "created"
    projection_type    = "INCLUDE"
    non_key_attributes = ["BetId", "State", "Bet", "Result", "ParentBetId"]
    read_capacity      = 0
    write_capacity     = 0
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
  point_in_time_recovery {
    enabled = true
  }
  replica {
    region_name = "eu-west-1"
  }
  replica {
    region_name = "ap-southeast-1"
  }


  timeouts {
    create = "30m"
  }
  tags = {
    Environment = "${local.environment}"
  }
}
