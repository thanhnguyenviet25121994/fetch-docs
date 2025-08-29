locals {
  alb_name            = regex("loadbalancer/(.+)", aws_lb.prod.arn)[0]
  cache_cluster_id    = "${local.environment}-service-game-client"
  dynamodb_table_name = "${local.environment}_bet_results"

  ecs_clusters = {
    "service-game-client"     = ["service-game-client", "service-game-client-2"],
    "service-pp-adaptor"      = ["service-pp-adaptor"],
    "share-ui-game-client"    = ["share-ui-game-client"],
    "service-static-router"   = ["service-static-router"],
    "operator-demo"           = ["operator-demo"],
    "service-transfer-wallet" = ["service-transfer-wallet"],
    "service-pgs-adaptor"     = ["service-pgs-adaptor"],
    "service-hacksaw-adaptor" = ["service-hacksaw-adaptor"],
    "service-jili-adapter"    = ["service-jili-adapter"],
  }
  # target_groups = {
  target_groups = {
    "service-transfer-wallet" = {
      suffix = aws_lb_target_group.prod_service_transfer_wallet.arn_suffix
      alb_alarms = {
        enable       = false
        requestCount = 1000
      }
    }

    "service-game-client" = {
      suffix = aws_lb_target_group.prod_service_game_client.arn_suffix
      alb_alarms = {
        enable       = true
        requestCount = 50000
      }
    }

    "service-game-client-2" = {
      suffix = aws_lb_target_group.prod_service_game_client_2.arn_suffix
      alb_alarms = {
        enable       = false
        requestCount = 1000
      }
    }

    "service-pp-adaptor" = {
      suffix = aws_lb_target_group.prod_service_pp_adaptor.arn_suffix
      alb_alarms = {
        enable       = false
        requestCount = 1000
      }
    }

    "operator-demo" = {
      suffix = aws_lb_target_group.prod_operator_demo.arn_suffix
      alb_alarms = {
        enable       = false
        requestCount = 1000
      }
    }

    "service-jili-adapter" = {
      suffix = aws_lb_target_group.prod_service_jili_adapter.arn_suffix
      alb_alarms = {
        enable       = false
        requestCount = 1000
      }
    }

    "share-ui-game-client" = {
      suffix = "targetgroup/prod-share-ui-game-client/ba6f3b13d6f4927f"
      alb_alarms = {
        enable       = false
        requestCount = 1000
      }
    }

    "service-pgs-adaptor" = {
      suffix = aws_lb_target_group.prod_service_pgs_adaptor.arn_suffix
      alb_alarms = {
        enable       = false
        requestCount = 1000
      }
    }

    "service-hs-adaptor" = {
      suffix = aws_lb_target_group.prod_service_hacksaw_adaptor.arn_suffix
      alb_alarms = {
        enable       = false
        requestCount = 1000
      }
    }

    "service-wf-adapter" = {
      suffix = aws_lb_target_group.prod_service_wf_adapter.arn_suffix
      alb_alarms = {
        enable       = false
        requestCount = 1000
      }
    }

    # Add all other target groups here
  }


  target_group_alarms = flatten([
    for service, config in local.target_groups : concat([
      # for id in ids : [
      # 4XX Errors Alarm
      {
        type                = 2
        alarm_name          = "[HIGH]${local.environment}-ALB-Target-HTTP-4XX-Error-Count-greater-than-200-in-5-minutes(${service})"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = 200
        evaluation_periods  = 5
        datapoints_to_alarm = 5
        treat_missing_data  = "notBreaching"
        period              = 60
        alarm_description   = "This metric monitors ALB Target HTTP 4XX Error Count for ${service}"
        namespace           = "AWS/ApplicationELB"
        statistic           = "Sum"
        metric_query = [
          {
            id          = "e1"
            expression  = "SUM([m1])"
            label       = "${local.environment}-${service}"
            return_data = true
          },
          {
            id = "m1"
            metric = {
              metric_name = "HTTPCode_Target_4XX_Count"
              namespace   = "AWS/ApplicationELB"
              period      = 60
              stat        = "Sum"
              unit        = "Count"
              dimensions = {
                TargetGroup  = "${config.suffix}"
                LoadBalancer = local.alb_name
              }
            },
            label       = "HTTPCode_Target_4XX_Count",
            return_data = false
          }
        ]
      },
      # 5XX Errors Alarm
      {
        type                = 2
        alarm_name          = "[HIGH]${local.environment}-ALB-Target-HTTP-5XX-Error-Count-greater-than-100-in-5-minutes(${service})"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = 100
        evaluation_periods  = 5
        datapoints_to_alarm = 5
        treat_missing_data  = "notBreaching"
        period              = 60
        alarm_description   = "This metric monitors ALB Target HTTP 5XX Error Count for ${service}"
        namespace           = "AWS/ApplicationELB"
        statistic           = "Sum"
        metric_query = [
          {
            id          = "e1"
            expression  = "SUM([m1])"
            label       = "${local.environment}-${service}"
            return_data = true
          },
          {
            id = "m1"
            metric = {
              metric_name = "HTTPCode_Target_5XX_Count"
              namespace   = "AWS/ApplicationELB"
              period      = 60
              stat        = "Sum"
              unit        = "Count"
              dimensions = {
                TargetGroup  = "${config.suffix}"
                LoadBalancer = local.alb_name
              }
            },
            label       = "HTTPCode_Target_5XX_Count",
            return_data = false
          }
        ]
      },
      {
        type                = 2
        alarm_name          = "[HIGH]${local.environment}-ALB-Target-Response-Time-greater-than-1.5-second-in-5-minutes(${service})"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = 1.5
        evaluation_periods  = 10
        datapoints_to_alarm = 5
        treat_missing_data  = "notBreaching"
        period              = 120
        alarm_description   = "This metric monitors ALB Target Response Time for ${service}"
        namespace           = "AWS/ApplicationELB"
        statistic           = "Average"
        metric_query = [
          {
            id          = "e1"
            expression  = "AVG([m1])"
            label       = "${local.environment}-${service}"
            return_data = true
          },
          {
            id = "m1"
            metric = {
              metric_name = "TargetResponseTime"
              namespace   = "AWS/ApplicationELB"
              period      = 120
              stat        = "Average"
              unit        = "Seconds"
              dimensions = {
                TargetGroup  = "${config.suffix}"
                LoadBalancer = local.alb_name
              }
            },
            label       = "TargetResponseTime",
            return_data = false
          }
        ]
      }

      ],
      config.alb_alarms.enable ? [{
        type                = 2
        alarm_name          = "[HIGH]${local.environment}-ALB-Request-Count-above-${config.alb_alarms.requestCount}-in-2-minutes(${service})"
        comparison_operator = "GreaterThanThreshold"
        threshold           = config.alb_alarms.requestCount
        evaluation_periods  = 2
        datapoints_to_alarm = 2
        treat_missing_data  = "notBreaching"
        period              = 60
        alarm_description   = "Monitors request count for ${service} (threshold: ${config.alb_alarms.requestCount})"
        namespace           = "AWS/ApplicationELB"
        statistic           = "Sum"
        metric_query = [
          {
            id          = "e1"
            expression  = "SUM([m1])"
            label       = "${local.environment}-${service}"
            return_data = true
          },
          {
            id = "m1"
            metric = {
              metric_name = "RequestCount"
              namespace   = "AWS/ApplicationELB"
              period      = 60
              stat        = "Sum"
              unit        = "Count"
              dimensions = {
                TargetGroup  = "${config.suffix}"
                LoadBalancer = local.alb_name
              }
            }
            label       = "RequestCount"
            return_data = false
          }
        ]
    }] : [])
    ]
  )


  cassandra_alarms = [
    {
      type                = 2 # Metric math type
      alarm_name          = "[HIGH]${local.environment}-Cassandra-bets-table-ReadCapacity-Utilization-greater-than-80-percent-in-5-minutes"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 80 # 80% utilization threshold
      evaluation_periods  = 5
      datapoints_to_alarm = 5
      period              = 60 # 60-second period
      treat_missing_data  = "notBreaching"
      alarm_description   = "Monitors read capacity utilization (consumed/provisioned) for bets table"

      metric_query = [
        # Expression showing utilization percentage
        {
          id          = "e1"
          expression  = "(m1/PERIOD(m1))/m2*100" # (Consumed/Period)/Provisioned as percentage
          label       = "${local.environment}-bets-table-read-utilization"
          return_data = true
        },
        # ConsumedReadCapacityUnits (as Sum)
        {
          id = "m1"
          metric = {
            metric_name = "ConsumedReadCapacityUnits"
            namespace   = "AWS/Cassandra"
            period      = 60
            stat        = "Sum"
            unit        = "Count"
            dimensions = {
              KeyspaceName = "prod_keyspace"
              TableName    = "bets"
            }
          },
          label       = "ConsumedReadCapacityUnits",
          return_data = false
        },
        # ProvisionedReadCapacityUnits (as Average)
        {
          id = "m2"
          metric = {
            metric_name = "ProvisionedReadCapacityUnits"
            namespace   = "AWS/Cassandra"
            period      = 60
            stat        = "Average"
            unit        = "Count"
            dimensions = {
              KeyspaceName = "prod_keyspace"
              TableName    = "bets"
            }
          },
          label       = "ProvisionedReadCapacityUnits",
          return_data = false
        }
      ]
    }
  ]

  ecs_service_monitoring_rules = flatten([
    for cluster, services in local.ecs_clusters : [
      for service in services : [
        {
          type                = 1
          alarm_name          = "[HIGH]${local.environment}-[${cluster}/${service}]-ECS-Fargate-CPU-Utilization-greater-than-80-percent-in-5-minutes"
          metric_name         = "CPUUtilization"
          comparison_operator = "GreaterThanOrEqualToThreshold"
          threshold           = "80"
          namespace           = "AWS/ECS"
          statistic           = "Average"
          period              = "60"
          evaluation_periods  = "5"
          datapoints_to_alarm = "5"
          dimensions          = { ClusterName = "${local.environment}-${cluster}", ServiceName = service }
          alarm_description   = "This metric monitors ECS Fargate CPU utilization"
        },
        {
          type                = 1
          alarm_name          = "[HIGH]${local.environment}-[${cluster}/${service}]-ECS-Fargate-Memory-Utilization-greater-than-80-percent-in-5-minutes"
          metric_name         = "MemoryUtilization"
          comparison_operator = "GreaterThanOrEqualToThreshold"
          threshold           = "80"
          namespace           = "AWS/ECS"
          statistic           = "Average"
          period              = "60"
          evaluation_periods  = "5"
          datapoints_to_alarm = "5"
          treat_missing_data  = "missing"
          dimensions          = { ClusterName = "${local.environment}-${cluster}", ServiceName = service }
          alarm_description   = "This metric monitors ECS Fargate Memory utilization"
        },
        {
          type                = 1
          alarm_name          = "[HIGH]${local.environment}-[${cluster}/${service}]-ECS-Fargate-service-not-running-in-5-minutes"
          metric_name         = "RunningTaskCount"
          comparison_operator = "LessThanThreshold"
          threshold           = "1"
          namespace           = "ECS/ContainerInsights"
          statistic           = "Average"
          period              = "60"
          evaluation_periods  = "5"
          datapoints_to_alarm = "5"
          treat_missing_data  = "breaching"
          dimensions          = { ClusterName = "${local.environment}-${cluster}", ServiceName = service }
          alarm_description   = "This metric monitors if the ECS Fargate service has all tasks not running"
        }
      ]
    ]
  ])

  alarms = concat(
    [
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-EC2-Bastion-CPU-Utilization-greater-than-80-percent-in-5-minutes (only-for-testing)"
        metric_name         = "CPUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "80"
        namespace           = "AWS/EC2"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "1"
        datapoints_to_alarm = "1"
        treat_missing_data  = "missing"
        dimensions          = { InstanceId = "i-0568c62f08e00f5cc" }
        alarm_description   = "This metric monitors EC2 Bastion CPU utilization (only for testing purposes)"
      },

      ############ ALB Metrics ############
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-ALB-DDoS-Detection"
        metric_name         = "RequestCount"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "100000"
        namespace           = "AWS/ApplicationELB"
        statistic           = "Sum"
        period              = "60"
        evaluation_periods  = "1"
        datapoints_to_alarm = "1"
        treat_missing_data  = "missing"
        dimensions          = { LoadBalancer = "${local.alb_name}" }
        alarm_description   = "This metric monitors ALB Request Count for potential DDoS attacks"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-ALB-HTTP-4XX-Error-Count-greater-than-200-in-5-minutes"
        metric_name         = "HTTPCode_ELB_4XX_Count"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "200"
        namespace           = "AWS/ApplicationELB"
        statistic           = "Sum"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "ignore"
        dimensions          = { LoadBalancer = "${local.alb_name}" }
        alarm_description   = "This metric monitors ALB HTTP 4XX Error Count"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-ALB-Target-HTTP-4XX-Error-Count-greater-than-200-in-5-minutes"
        metric_name         = "HTTPCode_Target_4XX_Count"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "200"
        namespace           = "AWS/ApplicationELB"
        statistic           = "Sum"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "notBreaching"
        dimensions          = { LoadBalancer = "${local.alb_name}" }
        alarm_description   = "This metric monitors ALB Target HTTP 4XX Error Count"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-ALB-Target-Response-Time-greater-than-1.5-second-in-5-minutes"
        metric_name         = "TargetResponseTime"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "1.5"
        namespace           = "AWS/ApplicationELB"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { LoadBalancer = "${local.alb_name}" }
        alarm_description   = "This metric monitors ALB Target Response Time"
      },

      ############ RDS Metrics ############
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-RDS-CPU-Utilization-greater-than-80-percent-in-5-minutes"
        metric_name         = "CPUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "80"
        namespace           = "AWS/RDS"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { DBClusterIdentifier = aws_rds_cluster.prod_main.id }
        alarm_description   = "This metric monitors RDS CPU utilization"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-RDS-Freeable-Memory-less-than-5GB-in-5-minutes"
        metric_name         = "FreeableMemory"
        comparison_operator = "LessThanOrEqualToThreshold"
        threshold           = "5000000000" # 5 GB in bytes
        namespace           = "AWS/RDS"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { DBClusterIdentifier = aws_rds_cluster.prod_main.id }
        alarm_description   = "This metric monitors RDS Freeable Memory"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-RDS-Database-Connections-greater-than-400-in-5-minutes"
        metric_name         = "DatabaseConnections"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "400"
        namespace           = "AWS/RDS"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { DBClusterIdentifier = aws_rds_cluster.prod_main.id }
        alarm_description   = "This metric monitors RDS Database Connections"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-RDS-ACU-Utilization-greater-than-40-percent-in-5-minutes(prod-20240401172951182500000002)"
        metric_name         = "ACUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "40"
        namespace           = "AWS/RDS"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { DBClusterIdentifier = "prod-20240401172951182500000002" }
        alarm_description   = "This metric monitors RDS ACU utilization"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-RDS-ACU-Utilization-greater-than-40-percent-in-5-minutes(20240401173056008400000003)"
        metric_name         = "ACUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "40"
        namespace           = "AWS/RDS"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { DBInstanceIdentifier = "prod-20240401173056008400000003" }
        alarm_description   = "This metric monitors RDS ACU utilization"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-RDS-ACU-Utilization-greater-than-40-percent-in-5-minutes(20240702063758030600000001)"
        metric_name         = "ACUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "40"
        namespace           = "AWS/RDS"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { DBInstanceIdentifier = "prod-reader-20240702063758030600000001" }
        alarm_description   = "This metric monitors RDS ACU utilization"
      },

      ############ DynamoDB Metrics ############
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-DynamoDB-Consumed-Read-Capacity-Units-greater-than-80-percent-in-5-minutes"
        metric_name         = "ConsumedReadCapacityUnits"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "80"
        namespace           = "AWS/DynamoDB"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { TableName = "${local.dynamodb_table_name}" }
        alarm_description   = "This metric monitors DynamoDB Consumed Read Capacity Units"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-DynamoDB-Consumed-Write-Capacity-Units-greater-than-80-percent-in-5-minutes"
        metric_name         = "ConsumedWriteCapacityUnits"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "80"
        namespace           = "AWS/DynamoDB"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { TableName = "${local.dynamodb_table_name}" }
        alarm_description   = "This metric monitors DynamoDB Consumed Write Capacity Units"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-DynamoDB-Successful-Request-Latency-greater-than-100ms-in-5-minutes"
        metric_name         = "SuccessfulRequestLatency"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "100"
        namespace           = "AWS/DynamoDB"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions = {
          TableName = "${local.dynamodb_table_name}"
          Operation = "GetItem"
        }
        alarm_description = "This metric monitors DynamoDB Successful Request Latency"
      },

      ############ ElastiCache Valkey Metrics ############
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-ElastiCache-Valkey-Throttled-Requests-greater-than-2000-in-5-minutes"
        metric_name         = "ThrottledCmds"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "2000"
        namespace           = "AWS/ElastiCache"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "notBreaching"
        dimensions          = { clusterId = "${local.environment}-valkey" }
        alarm_description   = "This metric monitors ElastiCache Throttled Requests"
      },
    ],
    local.ecs_service_monitoring_rules,
    local.cassandra_alarms,
    local.target_group_alarms
  )
}

module "prod_cloudwatch_sns_topic" {
  source = "../../modules/cloudwatch-sns-topic"

  region           = local.region
  environment      = local.environment
  sns_topic_name   = "${local.environment}-sns-topic-for-cloudwatch-alarms"
  LARK_WEBHOOK_URL = "https://botbuilder.larksuite.com/api/trigger-webhook/22d17a154e679c2fa09fb85e444c7d90"
}

module "prod_monitoring" {
  source   = "../../modules/cloudwatch-alarm"
  for_each = { for alarm in local.alarms : alarm.alarm_name => alarm }

  region              = local.region
  environment         = local.environment
  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  period              = each.value.period
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description
  datapoints_to_alarm = each.value.datapoints_to_alarm
  type                = each.value.type
  treat_missing_data  = try(each.value.treat_missing_data, null)
  namespace           = try(each.value.namespace, null)
  statistic           = try(each.value.statistic, null)
  dimensions          = try(each.value.dimensions, {})
  metric_name         = each.value.type == 1 ? try(each.value.metric_name, "") : null
  metric_queries      = try(each.value.metric_query, [])

  alarm_actions = [
    module.prod_cloudwatch_sns_topic.get_sns_topic_arn
  ]
  ok_actions = [
    module.prod_cloudwatch_sns_topic.get_sns_topic_arn
  ]
}
