resource "aws_s3_bucket" "this" {
  bucket = "revengegames-lambda-${var.app_env}"

}

# resource "aws_s3_object" "zip_file" {
#   bucket   = aws_s3_bucket.this.id
#   key      = "test.zip"
#   #   source   = "./lambda_function.zip"
# }

resource "aws_iam_role" "this" {
  name = "${var.app_env}-lambda-s3-role"

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
  name        = "${var.app_env}-lambda-s3-policy"
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
resource "aws_iam_role_policy_attachment" "lambda_insights" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
}

resource "aws_lambda_function" "lambda_function" {
  for_each      = tomap(var.services)
  function_name = "${var.app_env}-${each.key}"
  architectures = each.value.lambda_architectures
  description   = "${each.key} to Lambda"
  s3_bucket     = aws_s3_bucket.this.id
  s3_key        = "test.zip"
  handler       = each.value.handler
  role          = aws_iam_role.this.arn
  # publish = var.app_env == "prod" ? true : false

  runtime                        = var.lambda_runtime
  timeout                        = var.lambda_function_timeout
  memory_size                    = each.value.memory_size
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

  tracing_config {
    mode = "PassThrough"
  }

  layers = var.lambda_function_layers

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
# available.logic-gates-of-olympus-clone



### hardcode because we are pushed these logics before, If change, we must redeploy all logic
resource "aws_lb_target_group" "services" {
  for_each    = tomap(var.services)
  name        = var.app_env == "mkt" && each.key == "logic-wisdom-of-athena-cloned" ? "lbd-mkt-logic-woa-cloned" : var.app_env == "mkt" && each.key == "logic-gates-of-olympus-1000-clone" ? "lbd-mkt-goo-1000-clone" : var.app_env == "mkt" && each.key == "logic-sweet-bonanza-1000-clone" ? "lbd-mkt-sb-1000-clone" : var.app_env == "mkt" && each.key == "logic-gates-of-olympus-clone" ? "lbd-mkt-goo-clone" : var.app_env == "mkt" && each.key == "logic-gates-of-olympus-xmas-clone" ? "lbd-mkt-goo-xmas-clone" : var.app_env == "mkt" ? trim(substr("lambda-mkt-${each.key}", 0, 32), "-") : each.key == "logic-chasing-leprechaun-coins-engine" ? "lbd-logic-chas-lep-coins-engine" : each.key == "logic-sweet-bonanza-1000-clone" ? "lbd-sweet-bonanza-1000-clone" : each.key == "logic-gates-of-olympus-1000-clone" ? "lbd-gates-of-olympus-1000-clone" : each.key == "logic-wisdom-of-athena-cloned" ? "logic-woa-cloned-${var.app_env}" : trim(substr("lambda-${each.key}", 0, 32), "-")
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

# locals {
#   service_order = [for k, v in merge(var.services, {}) : k]
# }

resource "aws_lb_listener_rule" "services" {
  for_each     = tomap(var.services)
  listener_arn = var.private_routes.load_balancer_listener.arn
  priority     = 610 + index(keys(var.services), each.key) + 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services[each.key].arn
  }

  condition {
    host_header {
      values = ["${each.key}.${var.private_routes.root_domain}", "${each.key}.${var.global_domain}"]
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



resource "aws_route53_zone" "private" {
  name = var.private_routes.root_domain

  vpc {
    vpc_id = var.network_configuration.vpc_id
  }

}

resource "aws_route53_record" "this" {
  for_each = tomap(var.services)

  zone_id = aws_route53_zone.private.id
  name    = "${each.key}.${var.private_routes.root_domain}"
  type    = "CNAME"
  ttl     = "60"
  records = [var.alb_dns_name]

}


data "aws_route53_zone" "global_private" {
  name         = var.global_domain
  private_zone = true
}

resource "aws_route53_record" "global" {
  for_each = tomap(var.services)

  zone_id = data.aws_route53_zone.global_private.id
  name    = "${each.key}.${var.global_domain}"
  type    = "CNAME"
  ttl     = "60"
  records = [var.alb_dns_name]

  latency_routing_policy {
    region = var.region # AWS region for this record
  }

  set_identifier = var.region

}

