#
resource "aws_codebuild_project" "this" {
  count        = var.create ? 1 : 0
  name         = "${var.app_name}-cdb"
  description  = "Codebuild for self-host github action runner"
  service_role = aws_iam_role.this.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"               # Update compute type for Windows
    image           = "aws/codebuild/windows-base:2019-3.0" # Update to a Windows image
    type            = "WINDOWS_SERVER_2019_CONTAINER"       # Use Windows Server 2019 container
    privileged_mode = true


  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/Revenge-Games/game-dragon-hatch.git"
    git_clone_depth = 1
    buildspec       = "override" # Indicate that the buildspec will be overridden by CodeBuild

  }
  source_version = "main"

}

resource "aws_codebuild_webhook" "this" {
  project_name = aws_codebuild_project.this[0].name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "WORKFLOW_JOB_QUEUED"
    }
  }
}


resource "aws_codebuild_source_credential" "example" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = ""
}

####################
### Role
####################

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = "CodeBuildPutObjectToS3"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::revengegames-dev",
      "arn:aws:s3:::revengegames-dev/*",
    ]
  }
}

resource "aws_iam_role_policy" "this" {
  role   = aws_iam_role.this.name
  policy = data.aws_iam_policy_document.this.json
}