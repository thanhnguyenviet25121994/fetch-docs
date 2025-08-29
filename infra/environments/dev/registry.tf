# ECR Cross-Region Replication Configuration
data "aws_caller_identity" "current" {}

resource "aws_ecr_replication_configuration" "replication_ap_southeast_1" {
  provider = aws.current

  replication_configuration {
    rule {
      destination {
        region      = "ap-northeast-1"
        registry_id = data.aws_caller_identity.current.account_id
      }
      destination {
        region      = "sa-east-1"
        registry_id = data.aws_caller_identity.current.account_id
      }
      # destination {
      #   region      = "ca-central-1"
      #   registry_id = data.aws_caller_identity.current.account_id
      # }
      destination {
        region      = "eu-west-1"
        registry_id = data.aws_caller_identity.current.account_id
      }
    }
  }
}

resource "aws_ecr_repository" "service_game_logic" {
  name                 = "revengegames/service-game-logic"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "service_game_client" {
  name                 = "revengegames/service-game-client"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_lifecycle_policy" "service_game_client" {
  repository = aws_ecr_repository.service_game_client.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire images older than 30 days"
        selection = {
          tagStatus   = "any"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
resource "aws_ecr_repository" "service_demo_operator_kotlin" {
  name                 = "revengegames/service-operator-demo-kotlin"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "service_entity" {
  name                 = "revengegames/service-entity"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "service_report" {
  name                 = "revengegames/service-report"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# TODO: replace this with a static build
resource "aws_ecr_repository" "service_portal_management" {
  name                 = "revengegames/portal-magement"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# TODO: replace this with a static build
resource "aws_ecr_repository" "service_portal_replay" {
  name                 = "revengegames/portal-replay"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# TODO: replace this with a static build
resource "aws_ecr_repository" "service_portal_lobby" {
  name                 = "revengegames/portal-lobby"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# resource "aws_ecr_repository" "service_fortune_dragon_logic" {
#   name                 = "revengegames/fortune-dragon-logic"
#   image_tag_mutability = "IMMUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

# resource "aws_ecr_repository" "logic_fortune_ox" {
#   name                 = "revengegames/logic-fortune-ox"
#   image_tag_mutability = "IMMUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

resource "aws_ecr_repository" "service-share-ui-game-client" {
  name                 = "revengegames/share-ui-game-client"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "service-share-ui-game-client" {
  repository = aws_ecr_repository.service-share-ui-game-client.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 20 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 20
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_repository" "service-web-landing-page" {
  name                 = "revengegames/web-landing-page"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "service-web-landing-page" {
  repository = aws_ecr_repository.service-web-landing-page.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_repository" "web_revenge_games" {
  name                 = "revengegames/web-revenge-games"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "portal_operator_2" {
  name                 = "revengegames/portal-operator-2"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
