module "mkt_lambda_service_logic_6" {
  source  = "../../modules/lambda-service-logic-global-mkt-2"
  app_env = local.environment
  region  = local.region
  network_configuration = {
    vpc_id = module.mkt_networking.vpc.id
    subnets = [
      module.mkt_networking.subnet_private_1.id,
      module.mkt_networking.subnet_private_2.id
    ]
    security_groups = [
      module.mkt_networking.vpc.default_security_group_id
    ]
  }
  private_routes = {
    enabled                = true
    root_domain            = "revenge-games.gmkt"
    load_balancer_listener = aws_lb_listener.lambda_private["lambda-6"]
  }
  alb_dns_name = aws_lb.lambda_private["lambda-6"].dns_name


  services = [
    {
      name                 = "logic-big-bass-xmas-xtreme-vs10bbxext-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-vampy-party-vswayswbounty-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-gems-bonanza-vs20goldfever-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-piza-piza-piza-vswayspizza-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-zeus-vs-hades-gods-of-war-vs15godsofwar-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-bigger-bass-splash-vs12bgrbspl-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-big-bass-halloween-2-vs10bhallbnza2-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-buffalo-king-megaways-vswaysbufking-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-super-ace-win-clonedacewin"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-battleship-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-eggy-pop"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fist-champion-clonedacewin"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-lucky-riches-ex-clonedacewin"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fortune-firecracker-clonedacewin"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-jump-for-rich-clonedacewin"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fortune-four-clonedacewin"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-pirate-treasure-clonedacewin"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-firecrackers-fortune-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-coin-flip"
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-battleship"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-mayan-empire-clonedacewin"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-super-bar-clonedacewin"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-tons-of-money-clonedacewin"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-hulao-battle-clonedacewin"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-zeus-clonedacewin"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lucky-panda"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fortune-snake"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-prosperity-dragon-golden-reel-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-prosperity-dragon-golden-reel"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-eggy-pop-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-farmageddon"
      env                  = local.default_env_lambda_logic
      handler              = "build/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-monopoly-mania"
      env                  = local.default_env_lambda_logic
      handler              = "build/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fiesta-red"
      env                  = local.default_env_lambda_logic
      handler              = "build/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fiesta-magenta"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-prosperity-clash"
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
  ]
}