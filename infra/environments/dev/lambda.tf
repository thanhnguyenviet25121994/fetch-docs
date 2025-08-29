locals {
  default_env_lambda_logic = {
    NODE_ENV            = "production"
    DEFAULT_RTP_PROFILE = "version_96"
    APP_ENV             = local.environment
    LOG_LEVEL           = "debug"
    VALIDATE_STATE      = true
    RG_LOG_NATIVE       = true
    RG_LOG_DEBUG        = true
  }
  default_handler              = "build/server.handler"
  default_lambda_architectures = ["arm64"]
  default_memory_size          = 128
}
module "dev_lambda_service_logic" {
  source  = "../../modules/lambda-service-logic"
  app_env = local.environment
  network_configuration = {
    vpc_id = module.dev_networking.vpc.id
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
  }
  private_routes = {
    enabled                = true
    root_domain            = "revenge-games.${local.environment}"
    load_balancer_listener = aws_lb_listener.http_private
  }
  alb_dns_name = aws_lb.dev_private.dns_name


  services = {
    logic-fortune-dragon = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    logic-amazing-circus = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size

    },

    logic-persian-gems = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size

    },
    logic-fortune-mouse-two = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size

    },
    logic-fortune-ox = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size

    },
    logic-sakura-neko = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    logic-legendary-el-toro = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    logic-super-phoenix = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    logic-god-of-fortune = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    logic-temple-of-gods = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    logic-fortune-ox-two = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    logic-gladiators = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    logic-fortune-tiger-two = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    logic-caramelo = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    logic-fortune-tiger-2 = {
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size

    },

    logic-wrath-of-zeus = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    logic-chasing-leprechaun-coins = {
      env = {
        NODE_ENV            = "production"
        DEFAULT_RTP_PROFILE = "version_97"
        APP_ENV             = local.environment
        LOG_LEVEL           = "debug"
      }
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    logic-empress-of-the-black-seas = {
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size


    },

    logic-aphrodite = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    logic-gems-of-olympus = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    logic-dragon-wonder = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },


    logic-lost-of-treasures = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    logic-sugar-rush = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

    logic-sweet-bonanza = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    logic-gates-of-olympus-1000 = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    logic-sweet-bonanza-1000 = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-lucky-snake = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    logic-lucky-duck = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    logic-lucky-fox = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    logic-doghouse = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    logic-lucky-unicorn = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    logic-lucky-turtle = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    logic-diamond-rise = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-candy-blitz-bombs-clone = {
      env = {
        NODE_ENV            = "production"
        DEFAULT_RTP_PROFILE = "version_97"
        APP_ENV             = local.environment
        LOG_LEVEL           = "debug"
      }
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-the-lone-fireball = {
      env = {
        NODE_ENV            = "production"
        DEFAULT_RTP_PROFILE = "version_97"
        APP_ENV             = local.environment
        LOG_LEVEL           = "debug"
      }
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-disco-fever = {
      env = {
        NODE_ENV            = "production"
        DEFAULT_RTP_PROFILE = "version_97"
        APP_ENV             = local.environment
        LOG_LEVEL           = "debug"
      }
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-solar-pong = {
      env = {
        NODE_ENV            = "production"
        DEFAULT_RTP_PROFILE = "version_97"
        APP_ENV             = local.environment
        LOG_LEVEL           = "debug"
      }
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-magic-circus = {
      env = {
        NODE_ENV            = "production"
        DEFAULT_RTP_PROFILE = "version_97"
        APP_ENV             = local.environment
        LOG_LEVEL           = "debug"
      }
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-tinkering-box = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-lucky-tiger-clone = {
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-sugar-rush-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-wild-west-duels-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size

    }
    logic-big-bass-splash-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }

    logic-caramelo-clonedrec = {
      env = {
        NODE_ENV             = "production"
        DEFAULT_RTP_PROFILE  = "version_96"
        APP_ENV              = local.environment
        LOG_LEVEL            = "debug"
        VALIDATE_STATE       = true
        RG_LOG_NATIVE        = true
        RG_LOG_DEBUG         = true
        RG_LOG_DEBUG_PLAYING = true
      }
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-test-caramelo-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-monopoly-mania-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-lucky-panda-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fortune-tiger-two-clonedrev = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-gold-party-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-sugar-rush-1000-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-sugar-rush-xmas-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-gates-of-olympus-xmas-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }

    logic-bigger-bass-blizzard-christmas-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-joker-jewels-hot-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-fiesta-blue = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-iron-valor = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-5-lions-gold-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-fiesta-green = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }

    logic-big-bass-bonanza-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-golden-year = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-path-of-gods = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-aphrodite-heart = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-firebird-quest = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-persian-jewels = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size

    }
    logic-lucky-leprechaun-loot = {
      env = {
        NODE_ENV            = "production"
        DEFAULT_RTP_PROFILE = "version_97"
        APP_ENV             = local.environment
        LOG_LEVEL           = "debug"
      }
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-mighty-toro = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-panda-fortune-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }

    logic-888-gold-clone = {
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-realm-of-thunder = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-rudolphs-gift = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    # logic-aphrodite-new-engine = {
    #   env                  = local.default_env_lambda_logic
    #   handler              = local.default_handler
    #   lambda_architectures = local.default_lambda_architectures
    #   memory_size          = local.default_memory_size
    # }
    logic-aztec-gems-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-doghouse-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-gates-of-olympus-1000-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-gates-of-olympus-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-jokers-jewels-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-star-light-princess-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-starlight-princess-1000-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-sweet-bonanza-1000-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-sweet-bonanza-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-sweet-bonanza-xmas-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-5-lions-megaways-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    # logic-fruit-party-clone = {
    #   env                  = local.default_env_lambda_logic
    #   handler              = local.default_handler
    #   lambda_architectures = local.default_lambda_architectures
    #   memory_size          = local.default_memory_size
    # }
    logic-himalayan-wild-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-lucky-year = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-smash-fury = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-3-buzzing-wild-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-wrath-of-zeus-clonedrev = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-temple-of-gods-clonedrev = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-sakura-neko-clonedrev = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    # logic-legendary-el-toro-clonedrev = {
    #   env                  = local.default_env_lambda_logic
    #   handler              = "dist/src/main.handler"
    #   lambda_architectures = local.default_lambda_architectures
    #   memory_size          = 256
    # }

    logic-fortune-ox-clonedrev = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fortune-tiger-2-clonedrev = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-god-of-fortune-clonedrev = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fortune-dragon-clonedrev = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fortune-hitn-roll-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-oodles-of-noodles-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-mystery-mice-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-yeti-quest-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-running-sushi-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-aztec-treasure-hunt-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-forging-wilds-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
  }

  depends_on = [aws_lb.dev_private]
}




module "dev_lambda_service_logic_2" {
  source  = "../../modules/lambda-service-logic-2"
  app_env = local.environment
  network_configuration = {
    vpc_id = module.dev_networking.vpc.id
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
  }
  private_routes = {
    enabled                = true
    root_domain            = "revenge-games.${local.environment}"
    load_balancer_listener = aws_lb_listener.http_private2
  }
  alb_dns_name = aws_lb.dev_private2.dns_name


  services = {
    logic-black-assassin = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-wild-west-gold-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-clover-gold-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-chests-of-cai-shen-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fiesta-magenta = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-eternal-empress-freeze-time-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-iron-valor-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    # logic-fiesta-blue-engine = {
    #   env                  = local.default_env_lambda_logic
    #   handler              = local.default_handler
    #   lambda_architectures = local.default_lambda_architectures
    #   memory_size          = local.default_memory_size
    # }
    # logic-fiesta-green-engine = {
    #   env                  = local.default_env_lambda_logic
    #   handler              = local.default_handler
    #   lambda_architectures = local.default_lambda_architectures
    #   memory_size          = local.default_memory_size
    # }
    logic-fiesta-red = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-farmageddon = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-tower = {
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-plinko = {
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-dice = {
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-the-dog-house-megaways-clone = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }

    ####### TODO: the logic is deployed to test new code
    logic-wisdom-of-athena-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-wisdom-of-athena-1000-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fruit-party-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-smash-fury-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-limbo = {
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-mine = {
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-lucky-panda = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-monopoly-mania = {
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-lucky-fox-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-lucky-duck-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-power-of-merlin-megaways-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-wild-wildebeest-wins-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fiesta-red-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-realm-of-thunder-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-black-assassin-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-the-lone-fireball-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-magic-circus-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-disco-fever-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-gladiators-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-lucky-turtle-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 384
    }
    logic-rudolphs-gift-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-chasing-leprechaun-coins-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fiesta-blue-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-legendary-el-toro-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-super-phoenix-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fiesta-green-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fiesta-magenta-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-lucky-year-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-crash = {
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-solar-pong-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-lucky-snake-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-persian-jewels-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-aphrodite-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-path-of-the-gods-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-pinata-wins-clonedpgs = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-empress-of-the-black-seas-clonedrev = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }

    logic-amazing-circus-clonedrev = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }

    logic-dragon-wonder-clonedrev = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }

    logic-farmageddon-clonedrec = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fonzos-feline-fortunes-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-big-bass-return-to-the-races-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-sumo-supreme-megaways-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-irish-crown-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-greedy-fortune-pig-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-savannah-legend-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-ancient-island-megaways-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-escape-the-pyramid-fire-ice-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-ratinho-sortudo-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-mining-rush-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-gold-diggers = {
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-luckys-wild-pub-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-dragon-king-hot-pots-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-wild-wild-pearls-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-big-bass-bonanza-3-reeler-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-triple-pot-gold-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-floating-dragon-year-of-the-snake-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-raging-waterfall-megaways-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-luckys-wild-pub-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-santas-xmas-rush-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-gem-elevator-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-the-dog-house-muttley-crew-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-badge-blitz-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fortune-tiger-clonedpgs = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fortune-rabbit-clonedpgs = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-angel-vs-sinner-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-dragon-gold-88-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-wheel = {
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-sugar-rush-1000-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fortune-dragon-clonedpgs = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fortune-mouse-clonedpgs = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-aztecs-mystery = {
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-lucky-neko-clonedpgs = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fortune-ox-clonedpgs = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256

    }
    logic-dragon-hatch-clonedpgs = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-double-fortune-clonedpgs = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-cash-mania-clonedpgs = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-keno = {
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-big-bass-vegas-double-down-deluxe-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-blackjack = {
      env                  = local.default_env_lambda_logic
      handler              = "build/src/server.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    }
    logic-hot-to-burn-7-deadly-free-spins-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-congo-cash-xl-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fortune-ox-two-clonedrev = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }

    logic-penguins-christmas-party-time-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-might-of-freya-megaways-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-moleionaire-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-fangtastic-freespins-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }
    logic-bow-of-artemis-cloned = {
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    }

  }

  depends_on = [aws_lb.dev_private2]
}




module "dev_lambda_service_logic_3" {
  source  = "../../modules/lambda-service-logic-3"
  app_env = local.environment
  network_configuration = {
    vpc_id = module.dev_networking.vpc.id
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
  }
  private_routes = {
    enabled                = true
    root_domain            = "revenge-games.${local.environment}"
    load_balancer_listener = aws_lb_listener.http_private3
  }
  alb_dns_name = aws_lb.dev_private3.dns_name


  services = [
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
      handler              = "build/server.handler"
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
      name                 = "logic-jack-frosts-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-jewels-prosper-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-candy-bonanza-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-yakuza-honor-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-leprechaun-riches-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lucky-clover-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-anubis-wrath-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-mafia-mayhem-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-mahjong-ways2-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-majestic-ts-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-win-win-fpc-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-mermaid-riches-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-bakery-bonanza-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-mystic-potions-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-myst-spirits-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-ninja-raccoon-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-oishi-delights-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-opera-dynasty-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fortune-snake"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },

  ]
}



module "dev_lambda_service_logic_4" {
  source  = "../../modules/lambda-service-logic-3"
  app_env = local.environment
  network_configuration = {
    vpc_id = module.dev_networking.vpc.id
    subnets = [
      module.dev_networking.subnet_private_1.id,
      module.dev_networking.subnet_private_2.id
    ]
    security_groups = [
      module.dev_networking.vpc.default_security_group_id
    ]
  }
  private_routes = {
    enabled                = true
    root_domain            = "revenge-games.${local.environment}"
    load_balancer_listener = aws_lb_listener.http_private4
  }
  alb_dns_name = aws_lb.dev_private4.dns_name


  services = [
    {
      name                 = "logic-phoenix-rises-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-choc-deluxe-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lobster-bobs-sea-food-vs20lobseafd-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-barnyard-megahays-megaways-vswaysmegahays-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-ice-lobster-vs20stickypos-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-big-bass-secrets-golden-lake-vs10bblotgl-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-aztec-powernudge-vs20sbpnudge-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-ripe-rewards-vs40stckwldlvl-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-the-dog-house-dog-or-alive-vs20doghouse2-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    # {
    #   name                 = "logic-big-burger-load-it-up-with-xtra-cheese-vs10bburger-cloned"
    #   env                  = local.default_env_lambda_logic
    #   handler              = "dist/src/main.handler"
    #   lambda_architectures = local.default_lambda_architectures
    #   memory_size          = 256
    # },
    {
      name                 = "logic-fire-portals-vs20portals-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-mighty-munching-melons-vs20mmmelon-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-strawberry-cocktail-vs10strawberry-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-pompeii-megareels-megaways-vswaysmegareel-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-big-bass-floats-my-boat-vs10bbfloats-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-the-alter-ego-vswaysalterego-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-trees-of-treasure-vs20treesot-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-big-burger-load-it-up-vs10bburger-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-graffiti-rush-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-mr-treas-fort-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-incan-wonders-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-rave-party-fvr-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-rio-fantasia-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-rise-of-apollo-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-rooster-rbl-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-safari-wilds-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-sct-cleopatra-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-battleground-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-shark-bounty-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-speed-winner-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-spirit-wonder-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-spr-golf-drive-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-captains-bounty-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-queen-banquet-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-three-cz-pigs-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-totem-wonders-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-tsar-treasures-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-vampires-charm-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-chaos-crew-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-forest-fortune-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-bloodthirst-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-the-bowery-boys-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-hopnpop-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-beast-below-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-break-bones-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-bouncy-bombs-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-benny-the-beer-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-buffalo-stacknsync-clonedhs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lokis-riches-vs20loksriches-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-sweet-bonanza-xmas-vs20sbxmas-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wild-west-duels-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-the-dog-house-vs20doghouse-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-gold-party-vs25goldparty-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-aztec-gems-vs5aztecgems-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-bigger-bass-blizzard-xmas-vs12bbbxmas-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-3-buzzing-wilds-vs20wildparty-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-sugar-rush-xmas-vs20sugrux-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-starlight-christmas-vs20schristmas-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-jokers-jewels-hot-vs10jokerhot-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-jokers-jewels-vs5joker-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fortune-mouse-two-clonedrev"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-lucky-ox-vs10fortnhsly-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-mermaid"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-mahjong"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-mochi-mochi"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-mysteries-of-pandora"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-rave-on"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-run-pug-run"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-samba-fiesta"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-sanguo"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-stallion-princess"
      env                  = local.default_env_lambda_logic
      handler              = local.default_handler
      lambda_architectures = local.default_lambda_architectures
      memory_size          = local.default_memory_size
    },
    {
      name                 = "logic-crypto-gold-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-queen-bounty-clonedpgs"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-fortune-snake-clonedrec"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-sugar-rush-vs20sugarrush-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-starlight-princess-1000-vs20starlightx-cloned"
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
      name                 = "logic-starlight-princess-vs20starlight-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wisdom-of-athena-vs20procount-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wisdom-of-athena-1000-vs20procountx-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-5-lions-gold-slot-vs243lionsgold-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-5-lions-megaways-vswayslions-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-big-bass-bonanza-vs10bbbonanza-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-eternal-empress-freeze-vswaysfreezet-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 256
    },
    {
      name                 = "logic-wild-wildebeest-wins-vswaysbufstamp-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
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
      name                 = "logic-bandit-megaways-vswaysbandit-cloned"
      env                  = local.default_env_lambda_logic
      handler              = "dist/src/main.handler"
      lambda_architectures = local.default_lambda_architectures
      memory_size          = 128
    },
    # {
    #   name                 = "logic-gates-of-olympus-super-scatter-vs20olympgold-cloned"
    #   env                  = local.default_env_lambda_logic
    #   handler              = "dist/src/main.handler"
    #   lambda_architectures = local.default_lambda_architectures
    #   memory_size          = 256
    # },
    # {
    #   name                 = "logic-jelly-candy-vs5jellyc-cloned"
    #   env                  = local.default_env_lambda_logic
    #   handler              = "dist/src/main.handler"
    #   lambda_architectures = local.default_lambda_architectures
    #   memory_size          = 256
    # }


  ]
}

module "dev_lambda_deploy_notify" {
  source = "../../modules/lambda-deploy-notify"

  app_env                   = local.environment
  aws_region                = local.region
  lambda_function_code_path = "../../lambda-function/ecs-deployment-notification"
  ecs_cluster_arn = [
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/dev-service-marketing-portal-adapter",
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/dev-service-game-client",
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/dev-openreplay",
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/dev-service-game-logic",
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/dev-pg-service",
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/sandbox-pg-service",
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/prod-pg-service",
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/dev-service-entity",
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/dev-service-operator",
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/dev-service-pp-adaptor",
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/dev-operator-demo",
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/dev-portal-replay",
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/dev-share-ui-game-client",
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/dev-service-marketing-2",
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/dev-web-landing-page",
    "arn:aws:ecs:ap-southeast-1:211125478834:cluster/sandbox-pg-service",
  ]
}

module "dev_lambda_batch_failed" {
  source = "../../modules/lambda-batch-failed-notify"

  app_env                   = local.environment
  aws_region                = local.region
  app_name                  = "batch-failed"
  lambda_function_code_path = "../../lambda-function/batch-failed-notification"
}


module "dev_lambda_batch_24h" {
  source = "../../modules/lambda-batch-24h"

  app_env                   = local.environment
  aws_region                = local.region
  app_name                  = "batch-24h"
  lambda_function_code_path = "../../lambda-function/lambda-batch-24h"

}

module "dev_lambda_proxy_oc" {
  source = "../../modules/lambda-proxy-oc"

  app_env                   = local.environment
  aws_region                = local.region
  app_name                  = "proxy-oc"
  lambda_function_code_path = "../../lambda-function/lambda-proxy-oc"

}