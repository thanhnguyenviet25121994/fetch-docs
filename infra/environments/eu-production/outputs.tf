output "network_info" {
  value = module.prd_eu_networking
}

output "alb_private_dns_1" {
  value = aws_lb.prd_eu_private.dns_name
}

output "alb_private_dns_2" {
  value = aws_lb.prd_eu_private2.dns_name
}

output "alb_private_dns_3" {
  value = aws_lb.prd_eu_private3.dns_name
}

output "aws_lb_listener_1" {
  value = aws_lb_listener.http_private
}

output "aws_lb_listener_2" {
  value = aws_lb_listener.http_private2
}

output "aws_lb_listener_3" {
  value = aws_lb_listener.http_private3
}

output "alb_arn" {
  value = aws_lb.prd_eu.arn
}
