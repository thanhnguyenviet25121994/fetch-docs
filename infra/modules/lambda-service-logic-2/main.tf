data "aws_s3_bucket" "selected" {
  bucket = "revengegames-lambda-${var.app_env}"
}
data "aws_iam_role" "selected" {
  name = "${var.app_env}-lambda-s3-role"
}


resource "aws_lambda_function" "lambda_function" {
  for_each      = tomap(var.services)
  function_name = "${var.app_env}-${each.key}"
  architectures = each.value.lambda_architectures
  description   = "${each.key} to Lambda"
  s3_bucket     = data.aws_s3_bucket.selected.id
  s3_key        = "test.zip"
  handler       = each.value.handler
  role          = data.aws_iam_role.selected.arn
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
  retention_in_days = 30
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
  name        = var.app_env == "mkt-eu" ? trim(substr("${each.key}-lbd2-mkt-eu", -30, -1), "-") : var.app_env == "mkt" ? trim(substr("${each.key}-lbd2-mkt", -30, -1), "-") : var.app_env == "mkt-asia" ? trim(substr("${each.key}-lbd-mkt-asia", -30, -1), "-") : trim(substr("${each.key}-lambda2", -30, -1), "-")
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
  priority     = 610 + index(keys(var.services), each.key) + 1

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



data "aws_route53_zone" "private" {
  name         = var.private_routes.root_domain
  private_zone = true
}

resource "aws_route53_record" "this" {
  for_each = tomap(var.services)

  zone_id = data.aws_route53_zone.private.id
  name    = "${each.key}.${var.private_routes.root_domain}"
  type    = "CNAME"
  ttl     = "60"
  records = [var.alb_dns_name]

}

