#module "dev_collect_error_logs" {
#  source = "../../modules/collect-error-logs"
#
#  region           = local.region
#  environment      = local.environment
#  log_group_name   = "${local.environment}-service-game-client"
#  lark_webhook_url = "https://botbuilder.larksuite.com/api/trigger-webhook/b158d945c0c767d720a1834cf3e83653"
#  filter_pattern   = "ERROR -\"o.s.w.reactive.socket.WebSocketHandler\" -\"Session mismatch\" -\"UNKNOWN\" -\"Missing bet setting\" -\"Game not found\""
#}
