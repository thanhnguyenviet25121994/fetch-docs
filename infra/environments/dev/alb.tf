module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name                  = "${local.project}-${local.environment}-alb"
  load_balancer_type    = "application"
  vpc_id                = module.dev_networking.vpc.id
  subnets               = [module.dev_networking.subnet_public_1.id, module.dev_networking.subnet_public_2.id]
  security_groups       = ["${module.dev_networking.vpc.default_security_group_id}"]
  create_security_group = false

  idle_timeout = 60

  target_groups = {
    service-marketing-portal-adapter = {
      name              = "${local.environment}-svc-mkt-portal-adapter"
      backend_protocol  = "HTTP"
      backend_port      = 9600
      create_attachment = false
      target_type       = "ip"
      health_check = {
        enable              = true
        interval            = 30
        path                = "/actuator/health"
        port                = "traffic-port"
        matcher             = "200-400"
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 5
      }
      protocol_version     = "HTTP1"
      deregistration_delay = 300
    }

    service-marketing-2 = {
      name              = "${local.environment}-service-marketing-2"
      backend_protocol  = "HTTP"
      backend_port      = 9600
      create_attachment = false
      target_type       = "ip"
      health_check = {
        enable              = true
        interval            = 30
        path                = "/actuator/health"
        port                = "traffic-port"
        matcher             = "200-400"
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 5
      }
      protocol_version     = "HTTP1"
      deregistration_delay = 300
    }

  }


  listeners = {
    ex-fixed-response = {
      port     = 80
      protocol = "HTTP"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Not found"
        status_code  = "404"
      }

      rules = {
        service-marketing-portal-adapter-http = {
          priority = 3
          actions = [{
            type             = "forward"
            target_group_key = "service-marketing-portal-adapter"
          }]

          conditions = [{
            host_header = {
              values = ["mkt.${local.environment}.${local.root_domain}"]
            }
          }]

        }
        service-marketing-2-http = {
          priority = 4
          actions = [{
            type             = "forward"
            target_group_key = "service-marketing-2"
          }]

          conditions = [{
            host_header = {
              values = ["studio.${local.environment}.${local.root_domain}", "studio.${local.environment}.${local.allstar_domain}", "studio.${local.environment}.${local.rectangle_domain}"]
            }
          }]

        }
      }
    }

  }


}

