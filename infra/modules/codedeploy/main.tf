data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "service_level_permissions" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:DescribeServices",
          "ecs:CreateTaskSet",
          "ecs:UpdateServicePrimaryTaskSet",
          "ecs:DeleteTaskSet",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
    ]
  })
}

resource "aws_iam_policy" "load_balancing_readonly" {
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Sid : "Statement1",
        Effect : "Allow",
        Action : [
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:Get*"
        ],
        Resource : "*"
      },
      {
        Sid : "Statement2",
        Effect : "Allow",
        Action : [
          "ec2:DescribeInstances",
          "ec2:DescribeClassicLinkInstances",
          "ec2:DescribeSecurityGroups"
        ],
        Resource : "*"
      },
      {
        Sid : "Statement3",
        Effect : "Allow",
        Action : "arc-zonal-shift:GetManagedResource",
        Resource : "arn:aws:elasticloadbalancing:*:*:loadbalancer/*"
      },
      {
        Sid : "Statement4",
        Effect : "Allow",
        Action : [
          "arc-zonal-shift:ListManagedResources",
          "arc-zonal-shift:ListZonalShifts"
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "load_balancing" {
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Action : "elasticloadbalancing:*",
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcClassicLink",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeClassicLinkInstances",
          "ec2:DescribeRouteTables",
          "ec2:DescribeCoipPools",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeVpcPeeringConnections",
          "cognito-idp:DescribeUserPoolClient"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : "iam:CreateServiceLinkedRole",
        Resource : "*",
        Condition : {
          "StringEquals" : {
            "iam:AWSServiceName" : "elasticloadbalancing.amazonaws.com"
          }
        }
      },
      {
        Effect : "Allow",
        Action : "arc-zonal-shift:*",
        Resource : "arn:aws:elasticloadbalancing:*:*:loadbalancer/*"
      },
      {
        Effect : "Allow",
        Action : [
          "arc-zonal-shift:ListManagedResources",
          "arc-zonal-shift:ListZonalShifts"
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_passrole_policy" {
  name        = "${var.env}-${var.app_name}-ecs-passrole-policy"
  description = "Allows ECS to pass roles"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          "arn:aws:iam::211125478834:role/dev-service",
          "arn:aws:iam::211125478834:role/prod-asia-service"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "s3_read_access" {
  name        = "${var.env}-${var.app_name}-S3ReadAccessPolicy"
  description = "Policy to allow read access to a specific S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::revengegames",
          "arn:aws:s3:::revengegames/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role" "app-service-codedeploy-role" {
  name               = "${var.env}-${var.app_name}-codedeploy-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  managed_policy_arns = [
    aws_iam_policy.service_level_permissions.arn,
    aws_iam_policy.load_balancing.arn,
    aws_iam_policy.load_balancing_readonly.arn,
    aws_iam_policy.ecs_passrole_policy.arn,
    aws_iam_policy.s3_read_access.arn
  ]
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.app-service-codedeploy-role.name
}


resource "aws_codedeploy_app" "app-service" {
  name             = "${var.env}-${var.app_name}"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "app-service-dg" {
  app_name               = aws_codedeploy_app.app-service.name
  deployment_group_name  = "${var.env}-${var.app_name}-dg"
  service_role_arn       = aws_iam_role.app-service-codedeploy-role.arn
  deployment_config_name = var.deployment_config_name

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = ["${var.alb_listener_arn}"]
      }
      target_group {
        name = var.target_group_blue_name
      }
      target_group {
        name = var.target_group_green_name
      }
    }
  }
}