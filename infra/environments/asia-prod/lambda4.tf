module "prod_asia_lambda_service_logic_4" {
  source  = "../../modules/lambda-service-logic-global-2"
  app_env = local.environment

  region = local.region
  network_configuration = {
    vpc_id = module.prod_asia_networking.vpc.id
    subnets = [
      module.prod_asia_networking.subnet_private_1.id,
      module.prod_asia_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prod_asia_networking.vpc.default_security_group_id
    ]
  }

  private_routes = {
    enabled                = true
    root_domain            = "revenge-games.global"
    load_balancer_listener = aws_lb_listener.http_private4
  }

  alb_dns_name = aws_lb.prod_asia_private4.dns_name

  services = [
    {
      name                 = "logic-himalayan-wild-clone"
      env                  = local.default_env_lambda_logic
      handler              = "build/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-888-gold-clone"
      env                  = local.default_env_lambda_logic
      handler              = "build/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-star-light-princess-clone"
      env                  = local.default_env_lambda_logic
      handler              = "build/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-panda-fortune-clone"
      env                  = local.default_env_lambda_logic
      handler              = "build/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lucky-tiger-clone"
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-diamond-rise"
      env                  = local.default_env_lambda_logic
      handler              = "build/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-sweet-bonanza-1000"
      env                  = local.default_env_lambda_logic
      handler              = "build/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-sugar-rush"
      env                  = local.default_env_lambda_logic
      handler              = "build/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-gems-of-olympus"
      env                  = local.default_env_lambda_logic
      handler              = "build/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },

    {
      name                 = "logic-gates-of-olympus-1000"
      env                  = local.default_env_lambda_logic
      handler              = "build/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-sweet-bonanza"
      env                  = local.default_env_lambda_logic
      handler              = "build/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dragons-domain-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-franks-farm-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-cloud-princess-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-cash-quest-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-donny-dough-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-gronks-gems-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-immortal-desire-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-evil-eyes-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-get-the-cheese-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-octo-attack-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-big-bass-bonanza-1000-vs10bbbnz1000-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lucky-dog-vs5luckydogly-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-cash-surge-vswayscashsurg-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-5-lions-reborn-vsways5lionsr-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-ride-the-lightning-vs9ridelightng-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-jelly-candy-vs5jellyc-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-bandit-megaways-vswaysbandit-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 128
    },
    {
      name                 = "logic-inmate-outcuss-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-resurrecting-riches-vswaysresurich-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-jokers-jewels-cash-vs5jokerjc-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-emotiwins-vs10emotiwins-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dog-house-royal-hunt-vs20dhsuper-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-book-of-monsters-vs20fatbook-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lucky-tiger-vs5luckytigly-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-witch-heart-vswayswildbrst-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-zombie-outbrk-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-doomsday-rampg-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-asgardian-rs-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-gdn-ice-fire-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-hawaiian-tiki-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wild-fireworks-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-legend-perseus-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-crypt-fortune-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-mahjong-ways-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-mask-carnival-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-ze-zeus-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-slayers-inc-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-cursed-crypt-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-jelly-slice-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-keepem-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-divine-drop-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-orb-of-destiny-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-cash-crew-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-rusty-curly-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-dawn-of-kings-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-tigre-sortudo-1000-vs5luckytig1k-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-christmas-big-bass-bonanza-vs10bxmasbnza-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-bigger-bass-bonanza-vs12bbb-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-big-bass-hold-spinner-vs10bbhas-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-santas-great-gifts-vs20porbs-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-sleeping-dragon-vs25sleepdrag-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-blitz-super-wheel-vs20lightblitz-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-volcano-goddess-vswaysvlcgds-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-5-lions-megaways-2-vsways5lions2-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-jumbo-safari-vs20jjjack-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lucky-monkey-vs5luckymly-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fist-of-destruction-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wanted-dead-or-wild-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-rip-city-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-le-bandit-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-duel-at-dawn-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fiesta-fortune-vs10gbseries-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-swaggy-caramelo-super"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-frkn-bananas-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-hand-of-anubis-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-rotten-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-stormforged-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-le-viking-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },


    {
      name                 = "logic-dead-man-riches-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-knockout-rich-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-5-lions-gold-vs243lionsgold-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-clover-gold-vs20mustanggld2-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-pandas-fortune-vs25pandagold-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wealthy-frog-vs5wfrog-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-roulette"
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-3-buzzing-wild-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-swaggy-caramelo-super-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wild-west-gold-slot-vs40wildwest-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-sugar-rush-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-big-bass-bonanza-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-sweet-bonanza-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-starlight-princess-1000-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-bigger-bass-blizzard-christmas-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-gates-of-olympus-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-jokers-jewels-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-aztec-gems-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-gold-party-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-joker-jewels-hot-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-gates-of-olympus-1000-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
  ]

  depends_on = [aws_lb.prod_asia_private4]
}