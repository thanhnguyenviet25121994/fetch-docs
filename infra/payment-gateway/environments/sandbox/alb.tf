module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "v9.11.0"

  name               = "${local.project_name}-${local.environment}"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = ["${module.elb_sg.security_group_id}"]
  idle_timeout       = 60

  # target groups
  target_groups = {
    for tg_name, tg in local.pg_services : tg_name => {
      name              = length(tg_name) < 25 ? "${local.environment}-${tg_name}" : substr("${local.environment}-${tg_name}", 0, 32)
      protocol          = "HTTP"
      port              = 8080
      create_attachment = false
      target_type       = "ip"
      health_check = {
        enable              = false
        interval            = 30
        path                = tg.healthcheck_path
        port                = "traffic-port"
        matcher             = "200-400"
        timeout             = 20
        healthy_threshold   = 2
        unhealthy_threshold = 10
      }
      protocol_version     = "HTTP1"
      deregistration_delay = 30
    }
  }

  listeners = {
    ex-http = {
      port     = 80
      protocol = "HTTP"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Not found"
        status_code  = "404"
      }
      rules = merge({
        for tg_name, tg in local.pg_services : tg_name => {
          #   priority = 100 + index(keys(sort([for service in keys(local.pg_services) : service])), tg_name) + 1
          priority = 100 + index(keys(local.pg_services), tg_name) + 1
          actions = [{
            type             = "forward"
            target_group_key = tg_name
          }]
          conditions = tg.conditions

        }
        },
        {
      })
    }


  }
}
