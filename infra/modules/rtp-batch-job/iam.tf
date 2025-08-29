####################################
## IAM
####################################

## Instance role:
resource "aws_iam_role" "instance" {
  count = var.created && var.create_instance_iam_role ? 1 : 0

  name        = "${local.name}-instance"
  description = "Role for ${local.name}-instance"
  tags        = local.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "instance" {
  count = var.created && var.create_instance_iam_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.instance[0].name
}

resource "aws_iam_instance_profile" "instance" {
  count = var.created && var.create_instance_iam_role ? 1 : 0

  name = "${local.name}-instance"
  role = aws_iam_role.instance[0].name
  tags = local.tags
}

## Service Role:
resource "aws_iam_role" "service" {
  count = var.created && var.create_service_iam_role ? 1 : 0

  name        = "${local.name}-service"
  description = "Role for ${local.name}-service"
  tags        = local.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "batch.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "service" {
  count = var.created && var.create_service_iam_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
  role       = aws_iam_role.service[0].name
}

## Spot Fleet Role:
resource "aws_iam_role" "spot_fleet" {
  count = var.created && var.create_spot_fleet_iam_role ? 1 : 0

  name        = "${local.name}-spot-fleet"
  description = "Role for ${local.name}-spot-fleet"
  tags        = local.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "spotfleet.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "spot_fleet" {
  count = var.created && var.create_spot_fleet_iam_role ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
  role       = aws_iam_role.spot_fleet[0].name
}

## task execute role:
resource "aws_iam_role" "task_exec" {
  count = var.created ? 1 : 0

  name = "${local.name}-task"

  assume_role_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "task_exec" {
  count = var.created ? 1 : 0

  name = "${local.name}-task"
  role = aws_iam_role.task_exec[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:DescribeLogGroups",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "events:PutRule",
          "events:DeleteRule",
          "events:DescribeRule",
          "events:DisableRule",
          "events:EnableRule",
          "events:PutTargets",
          "events:RemoveTargets",
          "events:List*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:SendCommand",
          "ssm:DescribeSessions",
          "ssm:StartSession",
          "ssmmessages:*"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role" "jobrole" {
  count = var.created ? 1 : 0
  name  = "${local.name}-jobrole"

  assume_role_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy" "jobrole_policy" {
  count = var.created ? 1 : 0
  name  = "${local.name}-jobrolepolicy"
  role  = aws_iam_role.jobrole[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "events:PutRule",
          "events:DeleteRule",
          "events:PutTargets",
          "events:RemoveTargets",
          "events:List*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
        ],
        Resource = "*"
      }
    ]
  })
}
