resource "aws_s3_bucket" "this" {
  bucket = "revengegames-lambda-clone-${var.app_env}"

}

# resource "aws_s3_object" "zip_file" {
#   bucket   = aws_s3_bucket.this.id
#   key      = "test.zip"
#   #   source   = "./lambda_function.zip"
# }

resource "aws_iam_role" "this" {
  name = "${var.app_env}-lambda-clone-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "this" {
  name        = "${var.app_env}-lambda-clone-s3-policy"
  description = "Policy to allow Lambda function to interact with S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${aws_s3_bucket.this.bucket}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AttachNetworkInterface"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeSecurityGroups"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_role_policy_attachment" "lambda_exec" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

######################
#######  EFS
#####################
resource "aws_efs_file_system" "lambda_fs" {
  creation_token = "${var.app_env}-lambda-efs"
  tags = {
    Name = "${var.app_env}-lambda-efs"
  }
}

resource "aws_efs_access_point" "lambda_access_point" {
  file_system_id = aws_efs_file_system.lambda_fs.id
  root_directory {
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = 755
    }
    path = "/"
  }
}

resource "aws_efs_mount_target" "lambda_efs_target" {
  file_system_id  = aws_efs_file_system.lambda_fs.id
  subnet_id       = var.network_configuration.subnets_lambda
  security_groups = var.network_configuration.security_groups
}

###### lambda


resource "aws_lambda_function" "lambda_function" {
  for_each      = tomap(var.services)
  function_name = "${var.app_env}-${each.key}"
  architectures = ["x86_64"]
  description   = "${each.key} to Lambda"
  s3_bucket     = aws_s3_bucket.this.id
  s3_key        = "test.zip"
  handler       = each.value.handler
  role          = aws_iam_role.this.arn
  # publish = var.app_env == "prod" ? true : false

  runtime                        = var.lambda_runtime
  timeout                        = var.lambda_function_timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.lambda_function_reserved_concurrent_executions

  dynamic "environment" {
    for_each = each.value.env != [] ? [each.value.env] : []
    content {
      variables = each.value.env
    }
  }

  dynamic "vpc_config" {
    for_each = var.enable_vpc ? [1] : []
    content {
      subnet_ids         = var.network_configuration.subnets
      security_group_ids = var.network_configuration.security_groups
    }
  }

  dynamic "file_system_config" {
    for_each = var.enable_file_system_config ? [1] : []
    content {
      arn              = aws_efs_access_point.lambda_access_point.arn
      local_mount_path = "/mnt/efs"
    }

  }


  tracing_config {
    mode = "PassThrough"
  }

  tags = {
    Name        = each.key
    Environment = var.app_env
  }
}

resource "aws_cloudwatch_log_group" "this" {
  for_each          = tomap(var.services)
  name              = "/aws/lambda/${var.app_env}-${each.key}"
  retention_in_days = 7
}

resource "aws_lambda_function_url" "services" {
  for_each           = var.app_env == "dev" ? tomap(var.services) : {}
  function_name      = aws_lambda_function.lambda_function[each.key].function_name
  authorization_type = "NONE"
}


# locals {
#   tld = regex("[a-z-_]*.[a-z-_]*$", var.public_routes.root_domain)
# }

# data "cloudflare_zone" "root" {
#   name = local.tld
# }

# resource "cloudflare_record" "services" {
#   for_each = var.public_routes.enabled ? var.services : {}
#   zone_id  = data.cloudflare_zone.root.zone_id
#   name     = "${each.key}-1.${var.public_routes.root_domain}"
#   content  = aws_lambda_function_url.services[each.key].function_url
#   type     = "CNAME"
#   proxied  = true

#   depends_on = [ aws_lambda_function_url.services ]
# }


# resource "aws_lambda_function_event_invoke_config" "lambda_function_event_invoke_config" {
#   function_name                = aws_lambda_function.lambda_function.function_name
#   qualifier                    = "$LATEST"
#   maximum_event_age_in_seconds = 21600
#   maximum_retry_attempts       = 0
# }

# Let's always have a target group, to utilize the LB's health-check
# functionality. It doesn't matter if the service is not going to be publicly
# available.
resource "aws_lb_target_group" "services" {
  for_each    = tomap(var.services)
  name        = var.app_env == "mkt" ? trim(substr("${each.key}-lambda-cl-mkt", -30, -1), "-") : trim(substr("${each.key}-lambda-cl", -30, -1), "-")
  target_type = "lambda"

  health_check {

    path                = "/health-check"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 300
    timeout             = 10
  }

}

resource "aws_lb_target_group_attachment" "this" {
  for_each         = tomap(var.services)
  target_group_arn = aws_lb_target_group.services[each.key].arn

  # TODO: divide function name and alias
  target_id         = aws_lambda_function.lambda_function[each.key].arn
  availability_zone = "all"

  depends_on = [aws_lambda_permission.this]


}


# resource "aws_lambda_provisioned_concurrency_config" "this" {
#   for_each                          = var.app_env == "prod" ? tomap(var.services) : {}
#   function_name                     = aws_lambda_function.lambda_function[each.key].function_name
#   provisioned_concurrent_executions = 5
#   qualifier                         = aws_lambda_function.lambda_function[each.key].version
# }

resource "aws_lb_listener_rule" "services" {
  for_each     = tomap(var.services)
  listener_arn = var.private_routes.load_balancer_listener.arn
  priority     = 1010 + index(keys(var.services), each.key) + 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services[each.key].arn
  }

  condition {
    host_header {
      values = ["${each.key}.${var.private_routes.root_domain}"]
    }
  }

  tags = {
    # Name = "${sort(keys(var.services))[index(keys(var.services), each.key)]}.${var.private_routes.root_domain}"
    Name = "${each.key}.${var.private_routes.root_domain}"
  }
}

resource "aws_lambda_permission" "this" {
  for_each      = tomap(var.services)
  function_name = aws_lambda_function.lambda_function[each.key].arn

  statement_id_prefix = "AllowExecutionFromALB-"
  principal           = "elasticloadbalancing.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = aws_lb_target_group.services[each.key].arn
}


resource "aws_route53_record" "this" {
  for_each = tomap(var.services)

  zone_id = var.aws_route53_zone_id
  name    = "${each.key}.${var.private_routes.root_domain}"
  type    = "CNAME"
  ttl     = "60"
  records = [var.alb_dns_name]

}

