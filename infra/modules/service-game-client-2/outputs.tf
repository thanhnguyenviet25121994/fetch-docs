output "get_aws_ecs_cluster" {
  value       = aws_ecs_cluster.this
  description = "The ECS cluster"
}

output "get_aws_ecs_service" {
  value       = module.ecs_svc_service_game_client
  description = "The ECS service"
}