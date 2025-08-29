locals {
  lambda_albs = {
    lambda-6 = {
      internal = true
      subnets = [
        module.prod_asia_networking.subnet_private_1.id,
        module.prod_asia_networking.subnet_private_2.id
      ]
    }
    # lambda-7 = {
    #   internal = true
    #   subnets = [
    #     module.prod_asia_networking.subnet_private_3.id,
    #     module.prod_asia_networking.subnet_private_4.id
    #   ]
    # }
  }
}

resource "aws_lb" "lambda_private" {
  for_each = local.lambda_albs

  name               = "${local.environment}-${each.key}"
  internal           = each.value.internal
  load_balancer_type = "application"
  security_groups    = [module.prod_asia_networking.vpc.default_security_group_id]
  subnets            = each.value.subnets

  enable_deletion_protection = true
  idle_timeout               = 3600

  tags = {
    Environment = local.environment
  }
}

resource "aws_lb_listener" "lambda_private" {
  for_each = aws_lb.lambda_private

  load_balancer_arn = each.value.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
}
