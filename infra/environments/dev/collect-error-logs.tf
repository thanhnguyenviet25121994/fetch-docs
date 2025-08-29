module "dev_collect_error_logs" {
  source = "../../modules/collect-error-logs"

  region           = local.region
  environment      = local.environment
  log_group_name   = "${local.environment}-service-game-client"
  lark_webhook_url = "https://botbuilder.larksuite.com/api/trigger-webhook/917f77e54b5e077557d8e623df9257f1"
  filter_pattern   = "ERROR -\"o.s.w.reactive.socket.WebSocketHandler\" -\"Session mismatch\" -\"UNKNOWN\" -\"Missing bet setting\""
}