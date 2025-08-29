locals {
  default_env_lambda_logic = {
    NODE_ENV            = "production"
    DEFAULT_RTP_PROFILE = "version_96"
    APP_ENV             = local.environment
    LOG_LEVEL           = "error"
    RG_LOG_NATIVE       = "true"
  }
  default_handler              = "build/server.handler"
  default_lambda_architectures = ["arm64"]
  default_memory_size          = 256

}
module "mkt_asia_lambda_service_logic" {
  source  = "../../modules/lambda-service-logic-global-mkt"
  app_env = local.environment

  region = local.region
  network_configuration = {
    vpc_id = module.mkt_asia_networking.vpc.id
    subnets = [
      module.mkt_asia_networking.subnet_private_1.id,
      module.mkt_asia_networking.subnet_private_2.id
    ]
    security_groups = [
      module.mkt_asia_networking.vpc.default_security_group_id
    ]
  }

  private_routes = {
    enabled                = true
    root_domain            = "revenge-games.gmkt"
    load_balancer_listener = aws_lb_listener.http_private
  }

  alb_dns_name = aws_lb.mkt_asia_private.dns_name


  services = [
    {
      name                 = "logic-wild-west-gold-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-clover-gold-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fruit-party-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-caramelo-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-chests-of-cai-shen-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    # {
    #   name                 = "logic-fiesta-magenta"
    #   env                  = local.default_env_lambda_logic
    #   handler              = "dist/src/main.handler"
    #   lambda_architectures = local.default_lambda_architectures
    #   memory_size         = 256
    # },
    {
      name                 = "logic-eternal-empress-freeze-time-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wisdom-of-athena-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wrath-of-zeus-clonedrev"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-sakura-neko-clonedrev"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fortune-ox-clonedrev"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fortune-tiger-2-clonedrev"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-god-of-fortune-clonedrev"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fortune-dragon-clonedrev"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fortune-hitn-roll-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-oodles-of-noodles-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-mystery-mice-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-yeti-quest-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-running-sushi-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-aztec-treasure-hunt-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-forging-wilds-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-gem-elevator-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-the-dog-house-muttley-crew-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-badge-blitz-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fortune-tiger-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fortune-rabbit-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-angel-vs-sinner-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dragon-gold-88-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-tower"
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-plinko"
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dice"
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wisdom-of-athena-1000-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-smash-fury-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-limbo"
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-mine"
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lucky-fox-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lucky-duck-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-power-of-merlin-megaways-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wild-wildebeest-wins-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fiesta-red-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-realm-of-thunder-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-black-assassin-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-the-lone-fireball-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-magic-circus-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-disco-fever-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-gladiators-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lucky-turtle-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-rudolphs-gift-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-chasing-leprechaun-coins-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fiesta-blue-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-legendary-el-toro-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-super-phoenix-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fiesta-green-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fiesta-magenta-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lucky-year-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-crash"
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-solar-pong-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lucky-snake-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-persian-jewels-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-iron-valor-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-aphrodite-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-path-of-the-gods-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fortune-tiger-two-clonedrev"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-pinata-wins-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-empress-of-the-black-seas-clonedrev"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-amazing-circus-clonedrev"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dragon-wonder-clonedrev"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-monopoly-mania-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lucky-panda-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-farmageddon-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fonzos-feline-fortunes-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-big-bass-return-to-the-races-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-sumo-supreme-megaways-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-irish-crown-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-greedy-fortune-pig-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-savannah-legend-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-ancient-island-megaways-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-escape-the-pyramid-fire-ice-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-ratinho-sortudo-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-mining-rush-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dragon-king-hot-pots-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wild-wild-pearls-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-big-bass-bonanza-3-reeler-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-triple-pot-gold-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-floating-dragon-year-of-the-snake-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-raging-waterfall-megaways-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-luckys-wild-pub-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-santas-xmas-rush-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wheel"
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-sugar-rush-1000-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fortune-dragon-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
  ]

  depends_on = [aws_lb.mkt_asia_private]
}


module "mkt_asia_lambda_service_logic_2" {
  source  = "../../modules/lambda-service-logic-global-mkt-2"
  app_env = local.environment

  region = local.region
  network_configuration = {
    vpc_id = module.mkt_asia_networking.vpc.id
    subnets = [
      module.mkt_asia_networking.subnet_private_1.id,
      module.mkt_asia_networking.subnet_private_2.id
    ]
    security_groups = [
      module.mkt_asia_networking.vpc.default_security_group_id
    ]
  }

  private_routes = {
    enabled                = true
    root_domain            = "revenge-games.gmkt"
    load_balancer_listener = aws_lb_listener.http_private2
  }

  alb_dns_name = aws_lb.mkt_asia_private2.dns_name

  services = [
    {
      name                 = "logic-fortune-mouse-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lucky-neko-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fortune-ox-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dragon-hatch-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-double-fortune-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-cash-mania-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-keno"
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-big-bass-vegas-double-down-deluxe-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-blackjack"
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-hot-to-burn-7-deadly-free-spins-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-congo-cash-xl-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fortune-ox-two-clonedrev"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-penguins-christmas-party-time-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-might-of-freya-megaways-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-moleionaire-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fangtastic-freespins-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-bow-of-artemis-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-jackpot-hunter-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dynamite-diggin-doug-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-jokers-jewels-wild-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-6-jokers-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-samurai-code-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wild-west-duele-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-big-bass-splash-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-cocktail-nite-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wild-bandito-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-midas-fortune-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-ganesha-gold-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wild-bounty-sd-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dragon-hatch2-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wild-ape-3258-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-ganesha-fortune-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-shaolin-soccer-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-treasures-aztec-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-piggy-gold-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-the-great-icescape-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-jurassic-kdm-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-sprmkt-spree-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-jungle-delight-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lucky-piggy-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-bikini-paradise-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-prosper-ftree-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dest-sun-moon-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-diner-delights-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-shaolin-master-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-museum-mystery-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fortune-snake-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-tinkering-box-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-aztecs-mystery-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-crank-it-up-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-sweet-kingdom-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-hand-of-midas-2-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-buffalo-king-untamed-megaways-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-medusas-stone-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-devilicious-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wildies-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-revenge-of-loki-megaways-vswaysloki-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-big-bass-bonanza-reel-action-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-heroic-spins-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-gold-diggers-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-inmate-outcuss"
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
      name                 = "logic-sweet-bonanza-vs20fruitsw-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-alchemy-gold-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-bali-vacation-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-buffalo-win-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dreams-of-macau-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-egypts-book-mystery-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-emoji-riches-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fruity-candy-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-futebol-fever-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-forge-wealth-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-galactic-gems-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-garuda-gems-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-geisha-revenge-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-gem-saviour-conquest-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-gemstones-gold-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-genies-wishes-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dragon-gold-88-vs10dgold88-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-hot-to-burn-multiplier-vs5hotbmult-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-starlight-princess-pachi-vswaysjapan-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-rise-of-pyramids-vswayshexhaus-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dwarf-dragon-vswaysspltsym-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-front-runner-odds-on-vs10frontrun-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-heart-of-cleopatra-vs20heartcleo-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fruity-treats-vs20fortbon-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-sweet-bonanza-1000-vs20fruitswx-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-candy-blitz-bombs-vs20candybltz2-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-release-the-bison-vs20bison-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-gates-of-olympus-vs20olympgate-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-gates-of-olympus-1000-vs20olympx-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dollar-dollar-chicken-dinner"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-btrfly-blossom-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dark-summoning-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dork-unit-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-aztec-twist-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-gladiator-legends-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-heist-stakes-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-inmate-outcuss-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },

  ]

  depends_on = [aws_lb.mkt_asia_private]
}



module "mkt_asia_lambda_filter_log_to_lark" {
  source = "../../modules/lambda-filter-log-to-lark"

  app_env                   = local.environment
  aws_region                = local.region
  app_name                  = "filter-log-to-lark"
  lambda_function_code_path = "../../lambda-function/filter-log-to-lark"
  lambda_env = {
    PROD_LARK_WEBHOOK_URL = "https://open.larksuite.com/open-apis/bot/v2/hook/2aaf2a93-acda-4272-87d0-9abb6097fc73"
    # PROD_OPERATOR_LARK_WEBHOOK_URL = "https://open.larksuite.com/open-apis/bot/v2/hook/dcbe5791-ed34-4a6f-b940-beb05189fff7"
    PROD_BIGWIN_LARK_WEBHOOK_URL = "https://open.larksuite.com/open-apis/bot/v2/hook/8e5f66d5-8887-405a-932b-d57c4bec80fd"
  }


}

resource "aws_cloudwatch_log_subscription_filter" "sgc_lambda_destination" {
  name            = "ErrorFilter"
  log_group_name  = "mkt-asia-service-game-client"
  filter_pattern  = "ERROR -\"o.s.w.reactive.socket.WebSocketHandler\" -\"Session mismatch\" -\"UNKNOWN\" -\"Missing bet setting\" -\"Game not found\""
  destination_arn = module.mkt_asia_lambda_filter_log_to_lark.lambda_function_arn
  distribution    = "ByLogStream"
}