resource "aws_lb_listener_rule" "apibrl_host_header" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 201

  action {
    type             = "forward"
    order            = 1
    target_group_arn = aws_lb_target_group.prod_service_game_client.arn

  }

  condition {
    host_header {
      values = ["apibrl.${local.root_domain}"]
    }
  }
}

resource "aws_lb_listener_rule" "favicon" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 175

  action {
    type  = "fixed-response"
    order = 1

    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }

  condition {
    path_pattern {
      values = ["/favicon.ico"]
    }
  }

  condition {
    host_header {
      values = [
        "api.${local.root_domain}",
        "apig.${local.root_domain}",
        "apibrl.${local.root_domain}"
      ]
    }
  }
}
