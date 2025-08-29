module "global_accelerator" {
  source = "terraform-aws-modules/global-accelerator/aws"

  version = "v3.0.0"

  name = "prod-global"

  flow_logs_enabled   = true
  flow_logs_s3_bucket = module.s3_log_bucket.s3_bucket_id
  flow_logs_s3_prefix = "prod-global"

  # Listeners
  listeners = {
    listener_1 = {
      client_affinity = "NONE"

      endpoint_groups = {
        ap_southeast_1 = {
          endpoint_group_region         = local.region
          health_check_port             = 80
          health_check_protocol         = "HTTP"
          health_check_path             = "/"
          health_check_interval_seconds = 10
          health_check_timeout_seconds  = 5
          healthy_threshold_count       = 2
          unhealthy_threshold_count     = 2
          traffic_dial_percentage       = 100

          # Health checks will show as unhealthy in this example because there
          # are obviously no healthy instances in the target group
          endpoint_configuration = [{
            client_ip_preservation_enabled = true
            endpoint_id                    = aws_lb.prod_asia.arn
            weight                         = 128
          }]
        }
        eu_west_1 = {
          endpoint_group_region         = "eu-west-1"
          health_check_port             = 80
          health_check_protocol         = "HTTP"
          health_check_path             = "/"
          health_check_interval_seconds = 10
          health_check_timeout_seconds  = 5
          healthy_threshold_count       = 2
          unhealthy_threshold_count     = 2
          traffic_dial_percentage       = 100

          # Health checks will show as unhealthy in this example because there
          # are obviously no healthy instances in the target group
          endpoint_configuration = [{
            client_ip_preservation_enabled = true
            endpoint_id                    = data.terraform_remote_state.prod_eu.outputs.alb_arn
            weight                         = 128
          }]
        }
        sa_east_1 = {
          endpoint_group_region         = "sa-east-1"
          health_check_port             = 80
          health_check_protocol         = "HTTP"
          health_check_path             = "/"
          health_check_interval_seconds = 10
          health_check_timeout_seconds  = 5
          healthy_threshold_count       = 2
          unhealthy_threshold_count     = 2
          traffic_dial_percentage       = 100

          # Health checks will show as unhealthy in this example because there
          # are obviously no healthy instances in the target group
          endpoint_configuration = [{
            client_ip_preservation_enabled = true
            endpoint_id                    = data.terraform_remote_state.prod.outputs.alb_arn
            weight                         = 128
          }]
        }
      }

      port_ranges = [
        {
          from_port = 80
          to_port   = 80
        }
      ]
      protocol = "TCP"
    }

  }

  listeners_timeouts = {
    create = "35m"
    update = "35m"
    delete = "35m"
  }

  endpoint_groups_timeouts = {
    create = "35m"
    update = "35m"
    delete = "35m"
  }

}



module "s3_log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "${local.project}-prod-ga-flowlogs"

  # Not recommended for production, required for testing
  force_destroy = true

  # Provides the necessary policy for flow logs to be delivered
  attach_lb_log_delivery_policy = true

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}