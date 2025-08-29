output "ecr_service_game_logic" {
  value = aws_ecr_repository.service_game_logic
}

output "ecr_service_game_client" {
  value = aws_ecr_repository.service_game_client
}

output "ecr_service_demo_operator_kotlin" {
  value = aws_ecr_repository.service_demo_operator_kotlin
}

output "ecr_service_entity" {
  value = aws_ecr_repository.service_entity
}

output "lambda_function_urls" {
  value = module.dev_lambda_service_logic.lambda_function_urls
}
output "network_info" {
  value = module.dev_networking
}

output "alb_private_dns_1" {
  value = aws_lb.dev_private.dns_name
}

output "alb_private_dns_2" {
  value = aws_lb.dev_private2.dns_name
}

output "alb_private_dns_3" {
  value = aws_lb.dev_private3.dns_name
}

output "alb_private_dns_4" {
  value = aws_lb.dev_private4.dns_name
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
output "aws_lb_listener_4" {
  value = aws_lb_listener.http_private4
}