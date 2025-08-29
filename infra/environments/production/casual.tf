resource "aws_s3_bucket" "ca" {
  bucket = "ca.rg-lgna.com"

  tags = {
    Name        = "revengegames-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_website_configuration" "ca" {
  bucket = aws_s3_bucket.ca.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "ca_public" {
  bucket = aws_s3_bucket.ca.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "ca_s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.ca.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.ca_public
  ]
}

resource "aws_s3_bucket_policy" "ca_allow_public_access" {
  bucket = aws_s3_bucket.ca.id
  policy = data.aws_iam_policy_document.ca_s3_allow_public_access.json
}


resource "cloudflare_record" "ca" {
  zone_id = data.cloudflare_zone.root.id
  name    = "ca"
  type    = "CNAME"
  content = module.cloudfront_ca.cloudfront_distribution_domain_name
  proxied = true

  allow_overwrite = true
}

module "cloudfront_ca" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "v3.4.0"

  aliases = [aws_s3_bucket.ca.bucket]
  comment = "CloudFront for Casual games (production)"

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  default_root_object = "index.html"

  viewer_certificate = {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:211125478834:certificate/ed6127af-7d88-4f93-a1a9-ad044a5155b6"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  origin = {
    s3 = {
      domain_name = "${aws_s3_bucket_website_configuration.ca.website_endpoint}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    elb = {
      domain_name = "${aws_lb.prod.dns_name}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
    elb_config = {
      domain_name = "${aws_lb.prod.dns_name}"
      origin_path = "/api/v1/client"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id             = "s3"
    allowed_methods              = ["HEAD", "GET"]
    cached_methods               = ["HEAD", "GET"]
    viewer_protocol_policy       = "allow-all"
    use_forwarded_values         = false
    cache_policy_name            = "Managed-CachingOptimized"
    origin_request_policy_name   = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
    response_headers_policy_name = "Managed-CORS-With-Preflight"
    compress                     = true
  }

  ordered_cache_behavior = [
    {
      path_pattern               = "/api/*"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods             = ["HEAD", "GET"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/client/*"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods             = ["HEAD", "GET"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/*/spin"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods             = ["HEAD", "GET"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/*/config"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "GET", "OPTIONS"]
      cached_methods             = ["HEAD", "GET", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/*/config.json"
      target_origin_id           = "elb_config"
      allowed_methods            = ["HEAD", "GET", "OPTIONS"]
      cached_methods             = ["HEAD", "GET", "OPTIONS"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true


    },
    {
      path_pattern               = "/*/env-config.js"
      target_origin_id           = "elb_config"
      allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods             = ["HEAD", "GET"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },

    {
      path_pattern               = "/*/version.json"
      target_origin_id           = "s3"
      allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
      cached_methods             = ["HEAD", "GET"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern                 = "/*/multiple.settings.json"
      target_origin_id             = "s3"
      allowed_methods              = ["HEAD", "GET"]
      cached_methods               = ["HEAD", "GET"]
      viewer_protocol_policy       = "allow-all"
      use_forwarded_values         = false
      cache_policy_name            = "Managed-CachingDisabled"
      origin_request_policy_name   = "Managed-CORS-S3Origin"
      response_headers_policy_name = "Managed-CORS-With-Preflight"
      compress                     = true

    },
    {
      path_pattern                 = "/*/launcher.settings.json"
      target_origin_id             = "s3"
      allowed_methods              = ["HEAD", "GET"]
      cached_methods               = ["HEAD", "GET"]
      viewer_protocol_policy       = "allow-all"
      use_forwarded_values         = false
      cache_policy_name            = "Managed-CachingDisabled"
      origin_request_policy_name   = "Managed-CORS-S3Origin"
      response_headers_policy_name = "Managed-CORS-With-Preflight"
      compress                     = true

    },
    {
      path_pattern               = "/*/env-config.*.js"
      target_origin_id           = "elb_config"
      allowed_methods            = ["HEAD", "GET"]
      cached_methods             = ["HEAD", "GET"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true

    },
    {
      path_pattern               = "/*/index.html"
      target_origin_id           = "s3"
      allowed_methods            = ["HEAD", "GET"]
      cached_methods             = ["HEAD", "GET"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
      compress                   = true
    },
    {
      path_pattern               = "/ws"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "GET"]
      cached_methods             = ["HEAD", "GET"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    },
    {
      path_pattern               = "/com.revenge.entity.v1.PlayService"
      target_origin_id           = "elb"
      allowed_methods            = ["HEAD", "GET"]
      cached_methods             = ["HEAD", "GET"]
      viewer_protocol_policy     = "allow-all"
      use_forwarded_values       = false
      cache_policy_name          = "Managed-CachingDisabled"
      origin_request_policy_name = "Managed-AllViewer"
      compress                   = true
    }
  ]
}


######################################################## 
# API for casual games
######################################################## 

module "service_game_client_casual" {
  source = "../../modules/service-game-client-new"
  providers = {
    aws = aws.current
  }

  ecs_cluster_arn = module.prod_service_game_client.get_aws_ecs_cluster.arn
  app_name        = "service-game-client-casual"

  instance_count_min = 1
  task_size_cpu      = 2048
  task_size_memory   = 4096

  app_env        = local.environment
  filter_pattern = "{ $.message = \"[ERROR]\" && $.message != \"*Error during WebSocket session*\" && $.message != \"*Handling error for session*\" }"

  image = "211125478834.dkr.ecr.${local.region}.amazonaws.com/revengegames/service-game-client:v1.0.1273.1"

  # opensearch = {
  #   endpoint    = module.prod_opensearch_2.endpoint
  #   credentials = data.aws_secretsmanager_secret.prod_service_game_client_db
  # }

  env = {
    "JAVA_OPTS" : "-Djava.net.preferIPv4Stack=true -XX:MaxMetaspaceSize=512m -Dspring.r2dbc.write.pool.max-size=8 -Dspring.r2dbc.write.pool.initial-size=4 -Dspring.r2dbc.read.pool.max-size=10 -Dspring.r2dbc.read.pool.initial-size=5 -Dspring.cloud.aws.cloudwatch.enabled=false -Dmanagement.metrics.enable.all=false -Dmanagement.tracing.enabled=false -Dmanagement.cloudwatch.metrics.export.enabled=false -XX:MaxDirectMemorySize=134217728 -Dlogging.level.com.revenge.game.features.play=OFF -Dlogging.level.com.revenge.game.features.play.ReportService=INFO"
    "MANAGEMENT_TRACING_ENABLED" : "false"
    "MANAGEMENT_TRACING_SAMPLING_PROBABILITY" : "0.1"
    "SERVICE_GAMEREPLAY_ENDPOINT" : "https://replay.${local.root_domain}/replay/"
    "GRPC_CLIENT_ENTITY_ADDRESS" : "http://service-entity-2-grpc.${local.environment}:81"
    "SERVICE_ENTITY_ADDRESS" : "https://entity.revenge-games.global"
    "AWS_DYNAMODB_TABLE_BETRESULTS" : "${local.environment}_bet_results"
    "ATTRIBUTE_DYNAMODBATTRIBUTESTABLE" : "${local.environment}_player_attributes"
    "AWS_DYNAMODB_TABLE_PLAYERATTRIBUTES" : "${local.environment}_player_attributes"
    "SYSTEM_DEBUG_ENABLED" : "true"
    "SERVICE_SHARED_UI_URL" : "https://share-ui-game-client.${local.root_domain}"
    "SERVICE_WEBSOCKET_URL" : "wss://cag.${local.root_domain}/ws"
    "SERVICE_WEBSOCKET_ENVURL" : "https://cag.${local.root_domain}"
    "SPRING_DATA_REDIS_HOST" : "prod-service-game-client.a5rxt5.0001.sae1.cache.amazonaws.com"
    "SPRING_DATA_REDIS_URL" : "rediss://${module.valkey_serverless_casual.serverless_cache_endpoint[0].address}:${module.valkey_serverless_casual.serverless_cache_endpoint[0].port}"
    "SERVICE_COMMON_ASSETS_URL" : "https://common-assets-v3.rg-lgna.com"
    "SYSTEM_LOGIC_VALIDATE" : false
    "FEATURES_HISTORY_IMPL" : "cassandra"
    "SPRING_CASSANDRA_KEYSPACE_NAME" : "${local.environment}_keyspace"
    "SPRING_CASSANDRA_CONTACT_POINTS" : "cassandra.${local.region}.amazonaws.com:9142"
    "SPRING_CASSANDRA_REQUEST_CONSISTENCY" : "local_quorum"
    "SPRING_CASSANDRA_LOCAL_DATACENTER" : "${local.region}"


  }

  role = aws_iam_role.prod_service
  network_configuration = {
    region = local.region
    vpc    = module.prod_networking.vpc
    subnets = [
      module.prod_networking.subnet_private_1.id,
      module.prod_networking.subnet_private_2.id
    ]
    security_groups = [
      module.prod_networking.vpc.default_security_group_id
    ]
    load_balancer_target_groups = [{
      arn  = aws_lb_target_group.prod_service_game_client_ca.arn,
      port = 9300
    }]
  }

  depends_on = [
    aws_iam_role.prod_service,
    aws_iam_role_policy.prod_service_policy,
  ]

}




resource "aws_lb_target_group" "prod_service_game_client_ca" {
  name        = "${local.environment}-service-game-client-ca"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.prod_networking.vpc.id
  target_type = "ip"

  health_check {
    path                = "/actuator/health"
    port                = "9300"
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }

  tags = {
    Environment = local.environment
  }
}

resource "aws_lb_listener_rule" "prod_service_game_client_ca" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 250

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_service_game_client_ca.arn
  }

  condition {
    host_header {
      values = ["ca.${local.root_domain}", "cag.${local.root_domain}"]
    }
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  tags = {
    Name        = "ca.${local.root_domain}"
    Environment = "${local.environment}"
  }
}



