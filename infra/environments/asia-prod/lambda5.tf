module "prod_asia_lambda_service_logic_5" {
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
    load_balancer_listener = aws_lb_listener.http_private5
  }

  alb_dns_name = aws_lb.prod_asia_private5.dns_name

  services = [

    {
      name                 = "logic-wild-west-duels-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-black-assassin"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-caramelo"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-disco-fever"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-doghouse-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-dragon-wonder"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-empress-of-the-black-seas"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fiesta-blue"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fiesta-green"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fortune-dragon"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fortune-mouse-two"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fortune-ox"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fortune-ox-two"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fortune-tiger-2"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fortune-tiger-two"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-gates-of-olympus-xmas-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-gladiators"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-god-of-fortune"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-gold-diggers"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-iron-valor"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-legendary-el-toro"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-lucky-duck"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-lucky-fox"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-lucky-snake"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-lucky-turtle"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-lucky-year"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-magic-circus"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-persian-gems"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-realm-of-thunder"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-rudolphs-gift"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-sakura-neko"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-smash-fury"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-solar-pong"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-sugar-rush-1000-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-sugar-rush-xmas-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-super-phoenix"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },




    {
      name                 = "logic-sweet-bonanza-1000-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-sweet-bonanza-xmas-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-temple-of-gods"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-the-dog-house-megaways-clone"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-the-lone-fireball"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-tinkering-box"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-wrath-of-zeus"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-chasing-leprechaun-coins"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-himalayan-wild-vs5himalaw-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-888-gold-vs5triple8gold-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-great-escape-killing"
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-craps"
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-ultimate-slot-of-america-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-spinman-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-pray-for-three-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-danny-dollar-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-rad-maxx-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-gates-of-hades-vs20gtsofhades-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-majestic-express-gold-run-vs25goldrexp-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-mahjong-wins-super-scatter-vswaysmwss-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-firecrackers-fortune"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-reign-of-rome-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fighter-pit-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-wishbringer-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-xmas-drop-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-life-and-death-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-wild-west-blazing-bounty-vs20wwgcluster-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-eye-of-spartacus-vs15eyeofspart-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-big-bass-boxing-bonus-round-vs10bbbbrnd-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-lucky-phoenix-vs5luckyphnly-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-o-vira-lata-caramelo-vs20caramsort-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-jeitinho-brasileiro-vs25jeitinho-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-temple-guardians-vs10diamondrgh-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-plushie-wins-vs1dragon888-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },




    {
      name                 = "logic-klowns-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-dorks-of-the-deep-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fire-my-laser-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-snow-slingers-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-marlin-master-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-strength-of-hercules-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-hounds-of-hell-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-phoenix-duelreels-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fortune-rabbit-clonedacewin"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-finger-lickn-free-spins-vs10fingerlfs-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-pig-farm-vs25pfarmfp-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-gold-party-2-after-hours-vs25goldpartya-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-ancient-island-megaways-vswaysmodfr-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-fonzos-feline-fortunes-vs10fonzofff-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    {
      name                 = "logic-irish-crown-vs20irishcrown-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-hades-inferno-1000-vs20hadex-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-candy-stash-bonanza-vs10cndstbnnz-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-mad-muertos-vs20mmuertx-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-games-in-olympus-1000-vs20olgamesx-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-sweet-cherry-blossom-vs20scbparty-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-startlight-wins-vswayssw-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-rise-of-ymir-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-wings-of-horus-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-booze-bash-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-freds-food-truck-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-le-king-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-7-clovers-of-fortune-vswayssevenc-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-wolf-gold-ultimate-vs25ultwolgol-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-candy-corner-vs20fourmc-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-tiny-toads-vs50fatfrogs-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

  ]


  depends_on = [aws_lb.prod_asia_private5]
}