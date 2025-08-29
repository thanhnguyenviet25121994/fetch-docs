# ##### code deploy
# module "codedeploy" {
#   source = "../../modules/codedeploy"

#   codedeploy_app_name     = "service-game-client-test"
#   ecs_cluster_name        = module.dev_service_game_client_test.get_aws_ecs_cluster.name
#   ecs_service_name        = module.dev_service_game_client_test.get_aws_ecs_service.name
#   alb_listener_arn        = aws_lb_listener.http.arn
#   target_group_blue_name  = aws_lb_target_group.dev_service_game_client_blue.name
#   target_group_green_name = aws_lb_target_group.dev_service_game_client_green.name
# }



# module "dev_service_game_client_test" {
#   providers = {
#     aws = aws.current
#   }

#   source        = "../../modules/service-game-client-test"
#   desired_count = 1

#   app_name = "service-game-client-test"

#   #   elasticache_node_type = "cache.t4g.medium"
#   task_size_cpu    = 2048
#   task_size_memory = 4096

#   filter_pattern = "{ $.message = \"[ERROR]\" && $.message != \"*Error during WebSocket session*\" && $.message != \"*Handling error for session*\" }"
#   app_env        = local.environment
#   image          = "${aws_ecr_repository.service_game_client.repository_url}:v1.0.852.1"
#   db = {
#     endpoint        = aws_rds_cluster.dev_main.endpoint
#     reader_endpoint = aws_rds_cluster.dev_main.reader_endpoint
#     credentials     = data.aws_secretsmanager_secret.dev_service_game_client_db
#     name            = "service_game_client"
#   }
#   opensearch = {
#     endpoint    = module.dev_opensearch_2.endpoint
#     credentials = data.aws_secretsmanager_secret.dev_service_game_client_db
#   }

#   env = {
#     "SERVICE_GAMEREPLAY_ENDPOINT" : "https://replay.dev.revenge-games.com/replay/"
#     "GRPC_CLIENT_ENTITY_ADDRESS" : "http://service-entity-grpc:81"
#     # "SYSTEM_DEBUG_ENABLED" : "true"
#     "SYSTEM_LOGIC_VALIDATE" : "true"
#     # "ORG_JOBRUNR_DASHBOARD_ENABLED" : "false"
#     # "ORG_JOBRUNR_BACKGROUND_JOB_SERVER_ENABLED" : "false"
#     "SERVICE_COMMON_ASSETS_URL" : "https://common-assets-v3.${local.environment}.${local.root_domain}"
#     "SERVICE_SHARED_UI_URL" : "https://share-ui-game-client.${local.environment}.${local.root_domain}"
#     "AWS_DYNAMODB_TABLE_PLAYERATTRIBUTES" : "dev_player_attributes"
#     "AWS_DYNAMODB_TABLE_BETRESULTS" : "dev_bet_results"
#     "SPRING_DATA_REDIS_URL" : "rediss://dev-cache-diqjla.serverless.apse1.cache.amazonaws.com:6379"
#   }

#   role = aws_iam_role.dev_service
#   network_configuration = {
#     region = "${local.region}"
#     vpc    = module.dev_networking.vpc
#     subnets = [
#       module.dev_networking.subnet_private_1.id,
#       module.dev_networking.subnet_private_2.id
#     ]
#     security_groups = [
#       module.dev_networking.vpc.default_security_group_id
#     ]
#     load_balancer_target_groups = [{
#       arn  = aws_lb_target_group.dev_service_game_client_blue.arn,
#       port = 9300
#     }]
#   }

#   services = {

#   }

#   depends_on = [
#     aws_iam_role.dev_service,
#     aws_iam_role_policy.dev_service_policy,
#   ]
# }

# resource "aws_lb_target_group" "dev_service_game_client_blue" {
#   name        = "${local.environment}-service-game-client-blue"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = module.dev_networking.vpc.id
#   target_type = "ip"

#   health_check {
#     path                = "/actuator/health"
#     healthy_threshold   = 5
#     unhealthy_threshold = 10
#   }

#   tags = {
#     Environment = local.environment
#   }
# }

# resource "aws_lb_target_group" "dev_service_game_client_green" {
#   name        = "${local.environment}-service-game-client-green"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = module.dev_networking.vpc.id
#   target_type = "ip"

#   health_check {
#     path                = "/actuator/health"
#     healthy_threshold   = 5
#     unhealthy_threshold = 10
#   }

#   tags = {
#     Environment = local.environment
#   }
# }



# resource "aws_lb_listener_rule" "dev_service_game_client_test" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 512

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.dev_service_game_client_blue.arn

#   }

#   condition {
#     host_header {
#       values = ["apitest.${local.environment}.${local.root_domain}"]
#     }
#   }

#   lifecycle {
#     ignore_changes = [action]
#   }


# }