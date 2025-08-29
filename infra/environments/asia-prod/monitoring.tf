locals {
  alb_name            = regex("loadbalancer/(.+)", aws_lb.prod_asia.arn)[0]
  cache_cluster_id    = "${local.environment}-service-game-client"
  dynamodb_table_name = "${local.environment}_bet_results"
  valkey_cluster_id   = "${local.environment}-valkey"

  ecs_clusters = {
    "service-game-client"     = ["service-game-client"],
    "service-pp-adaptor"      = ["service-pp-adaptor"],
    "service-entity"          = ["service-entity"],
    "portal-replay"           = ["portal-replay"],
    "share-ui-game-client"    = ["share-ui-game-client"],
    "service-static-router"   = ["service-static-router"],
    "operator-demo"           = ["operator-demo"],
    "service-transfer-wallet" = ["service-transfer-wallet"],
    "service-pgs-adaptor"     = ["service-pgs-adaptor"],
    "service-hacksaw-adaptor" = ["service-hacksaw-adaptor"],
    "service-jili-adapter"    = ["service-jili-adapter"],


  }

  target_groups = {
    "service-tw"          = aws_lb_target_group.prod_asia_service_transfer_wallet.arn_suffix
    "service-game-client" = aws_lb_target_group.prod_asia_service_game_client.arn_suffix
    "service-pp-adaptor"  = aws_lb_target_group.prod_asia_service_pp_adaptor.arn_suffix
    # "operator-demo"        = aws_lb_target_group.operator_demo.arn_suffix
    "service-jili-adapter" = aws_lb_target_group.prod_asia_service_jili_adapter.arn_suffix
    "service-entity-grpc"  = aws_lb_target_group.prod_asia_service_entity_grpc.arn_suffix
    "share-ui-game-client" = "targetgroup/prod-asia-share-ui-game-client/ed26e5fb532ef57e"
    "service-pgs-adaptor"  = aws_lb_target_group.prod_asia_service_pgs_adaptor.arn_suffix
    "service-hs-adaptor"   = aws_lb_target_group.prod_asia_service_hacksaw_adaptor.arn_suffix
    "service-wf-adapter"   = aws_lb_target_group.prod_asia_service_wf_adapter.arn_suffix
    # Add all other target groups here
  }

  # Generate alarms for each target group
  target_group_alarms = flatten([
    for service, suffix in local.target_groups : [
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
                TargetGroup  = "${suffix}"
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
                TargetGroup  = "${suffix}"
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
        evaluation_periods  = 5
        datapoints_to_alarm = 5
        treat_missing_data  = "missing"
        period              = 60
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
              period      = 60
              stat        = "Average"
              unit        = "Seconds"
              dimensions = {
                TargetGroup  = "${suffix}"
                LoadBalancer = local.alb_name
              }
            },
            label       = "TargetResponseTime",
            return_data = false
          }
        ]
      }
    ]
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



  #####Kinesis-specific thresholds (customize as needed)
  # kinesis_thresholds = {
  #   read_throttles        = 0      # Any read throttling is bad
  #   write_throttles       = 0      # Any write throttling is bad
  #   iterator_age_ms       = 300000 # 5 minutes in milliseconds
  #   incoming_bytes_pct    = 90     # Percentage of shard capacity (1MB/s)
  #   incoming_records_pct  = 90     # Percentage of record capacity (1000 recs/s)
  #   putrecord_failure_pct = 5      # Acceptable PutRecord failure percentage
  # }

  # kinesis_alarms = flatten([
  #   for stream in ["prod_asia_bet_result_stream"] : [
  #     # 3. CONSUMER LAG ALARMS (Standard metric)
  #     {
  #       type                = 1
  #       alarm_name          = "[HIGH] Kinesis-${stream}-Consumer-Lag"
  #       metric_name         = "GetRecords.IteratorAgeMilliseconds"
  #       namespace           = "AWS/Kinesis"
  #       statistic           = "Maximum"
  #       comparison_operator = "GreaterThanThreshold"
  #       threshold           = local.kinesis_thresholds.iterator_age_ms
  #       evaluation_periods  = 3
  #       datapoints_to_alarm = 3
  #       period              = 300
  #       dimensions          = { StreamName = stream }
  #       alarm_description   = "Consumer lag exceeding ${local.kinesis_thresholds.iterator_age_ms / 60000} minutes"
  #       treat_missing_data  = "notBreaching"

  #     },

  #     # 4. THROTTLING EVENT ALARMS (Standard metrics)
  #     {
  #       type                = 1
  #       alarm_name          = "[HIGH] Kinesis-${stream}-Write-Throttles"
  #       metric_name         = "WriteProvisionedThroughputExceeded"
  #       namespace           = "AWS/Kinesis"
  #       statistic           = "Sum"
  #       comparison_operator = "GreaterThanThreshold"
  #       threshold           = local.kinesis_thresholds.write_throttles
  #       evaluation_periods  = 1
  #       datapoints_to_alarm = 1
  #       period              = 60
  #       dimensions          = { StreamName = stream }
  #       alarm_description   = "Write throttling detected"
  #       treat_missing_data  = "notBreaching"

  #     },
  #     {
  #       type                = 1
  #       alarm_name          = "[HIGH] Kinesis-${stream}-Read-Throttles"
  #       metric_name         = "ReadProvisionedThroughputExceeded"
  #       namespace           = "AWS/Kinesis"
  #       statistic           = "Sum"
  #       comparison_operator = "GreaterThanThreshold"
  #       threshold           = local.kinesis_thresholds.read_throttles
  #       evaluation_periods  = 1
  #       datapoints_to_alarm = 1
  #       period              = 60
  #       dimensions          = { StreamName = stream }
  #       alarm_description   = "Read throttling detected"
  #       treat_missing_data  = "notBreaching"

  #     },

  #     # 5. DATA FLOW MONITORING (Standard metric)
  #     {
  #       type                = 1
  #       alarm_name          = "[HIGH] Kinesis-${stream}-No-Incoming-Data"
  #       metric_name         = "IncomingBytes"
  #       namespace           = "AWS/Kinesis"
  #       statistic           = "Sum"
  #       comparison_operator = "LessThanOrEqualToThreshold"
  #       threshold           = 0
  #       evaluation_periods  = 3
  #       datapoints_to_alarm = 3
  #       period              = 300
  #       dimensions          = { StreamName = stream }
  #       alarm_description   = "No incoming data detected for 15 minutes"
  #       treat_missing_data  = "notBreaching"

  #     }
  #   ]
  # ])

  kinesis_streams = ["prod_asia_bet_result_stream"]
  consumer_name   = "clickhouse-kinesis"

  kinesis_thresholds = {
    iterator_age_ms         = 43200000 # 12 hours (50% of default retention)
    getrecords_success_pct  = 95       # 95% success rate threshold
    putrecord_success_pct   = 95       # 95% success rate threshold  
    putrecords_failed_count = 100      # 100 failed records threshold
    read_throttle_count     = 5        # 5 throttled reads threshold
    write_throttle_count    = 5        # 5 throttled writes threshold
    millis_behind_latest    = 300000   # 5 minutes lag threshold
  }

  kinesis_alarms = flatten([
    for stream in local.kinesis_streams : [
      # 1. Iterator Age Alarm
      {
        type                = 1
        alarm_name          = "[CRITICAL] Kinesis-${stream}-High-Iterator-Age"
        metric_name         = "GetRecords.IteratorAgeMilliseconds"
        namespace           = "AWS/Kinesis"
        statistic           = "Maximum"
        comparison_operator = "GreaterThanThreshold"
        threshold           = local.kinesis_thresholds.iterator_age_ms
        evaluation_periods  = 15
        datapoints_to_alarm = 15
        period              = 60
        dimensions          = { StreamName = stream }
        alarm_description   = "Consumer lag exceeding ${local.kinesis_thresholds.iterator_age_ms / 3600000} hours. Risk of data expiration if approaching retention period."
        treat_missing_data  = "notBreaching"
      },

      # 2. GetRecords Success Rate Alarm
      {
        type                = 1
        alarm_name          = "[HIGH] Kinesis-${stream}-Low-GetRecords-Success"
        metric_name         = "GetRecords.Success"
        namespace           = "AWS/Kinesis"
        statistic           = "Average"
        comparison_operator = "LessThanThreshold"
        threshold           = local.kinesis_thresholds.getrecords_success_pct
        evaluation_periods  = 5
        datapoints_to_alarm = 5
        period              = 60
        dimensions          = { StreamName = stream }
        alarm_description   = "GetRecords success rate below ${local.kinesis_thresholds.getrecords_success_pct}%. Indicates consumer read failures."
        treat_missing_data  = "notBreaching"
      },

      # 3. PutRecord Success Rate Alarm
      {
        type                = 1
        alarm_name          = "[HIGH] Kinesis-${stream}-Low-PutRecord success count below 500 in 5 minutes"
        metric_name         = "PutRecord.Success"
        namespace           = "AWS/Kinesis"
        statistic           = "Sum" # Changed from Average to Sum
        comparison_operator = "LessThanThreshold"
        threshold           = 500 # New threshold of 5000 records
        evaluation_periods  = 5
        datapoints_to_alarm = 2
        period              = 60 # 60 seconds (1 minute)
        dimensions          = { StreamName = stream }
        alarm_description   = "PutRecord success count below 500 in 5 minutes. Indicates potential producer throughput issues or failures."
        treat_missing_data  = "breaching" # Changed to breaching for this use case
      },

      # 4. PutRecords Failed Records Alarm
      {
        type                = 1
        alarm_name          = "[HIGH] Kinesis-${stream}-High-PutRecords-Failures"
        metric_name         = "PutRecords.FailedRecords"
        namespace           = "AWS/Kinesis"
        statistic           = "Sum"
        comparison_operator = "GreaterThanThreshold"
        threshold           = local.kinesis_thresholds.putrecords_failed_count
        evaluation_periods  = 5
        datapoints_to_alarm = 5
        period              = 60
        dimensions          = { StreamName = stream }
        alarm_description   = "PutRecords failed records exceeding ${local.kinesis_thresholds.putrecords_failed_count}. Check for throughput issues."
        treat_missing_data  = "notBreaching"
      },

      # 5. Read Throttling Alarm
      {
        type                = 1
        alarm_name          = "[HIGH] Kinesis-${stream}-Read-Throttling"
        metric_name         = "ReadProvisionedThroughputExceeded"
        namespace           = "AWS/Kinesis"
        statistic           = "Average"
        comparison_operator = "GreaterThanThreshold"
        threshold           = local.kinesis_thresholds.read_throttle_count
        evaluation_periods  = 5
        datapoints_to_alarm = 5
        period              = 60
        dimensions          = { StreamName = stream }
        alarm_description   = "Read throttling exceeding ${local.kinesis_thresholds.read_throttle_count} events. Consider adding shards."
        treat_missing_data  = "notBreaching"
      },

      # 6. SubscribeToShard Lag Alarm
      {
        type                = 1
        alarm_name          = "[HIGH] Kinesis-${stream}-Consumer-Lag"
        metric_name         = "SubscribeToShardEvent.MillisBehindLatest"
        namespace           = "AWS/Kinesis"
        statistic           = "Average"
        comparison_operator = "GreaterThanThreshold"
        threshold           = local.kinesis_thresholds.millis_behind_latest
        evaluation_periods  = 5
        datapoints_to_alarm = 5
        period              = 60
        dimensions = {
          StreamName   = stream
          ConsumerName = local.consumer_name
        }
        alarm_description  = "Consumer lag exceeding ${local.kinesis_thresholds.millis_behind_latest / 60000} minutes. Check consumer performance."
        treat_missing_data = "notBreaching"
      },

      # 7. Write Throttling Alarm
      {
        type                = 1
        alarm_name          = "[HIGH] Kinesis-${stream}-Write-Throttling"
        metric_name         = "WriteProvisionedThroughputExceeded"
        namespace           = "AWS/Kinesis"
        statistic           = "Average"
        comparison_operator = "GreaterThanThreshold"
        threshold           = local.kinesis_thresholds.write_throttle_count
        evaluation_periods  = 5
        datapoints_to_alarm = 5
        period              = 60
        dimensions          = { StreamName = stream }
        alarm_description   = "Write throttling exceeding ${local.kinesis_thresholds.write_throttle_count} events. Consider adding shards."
        treat_missing_data  = "notBreaching"
      },
      {
        type                = 1
        alarm_name          = "[HIGH] Kinesis-${stream}-High-PutRecord-Latency exceeded 1000ms for 5 consecutive minutes."
        metric_name         = "PutRecord.Latency"
        namespace           = "AWS/Kinesis"
        statistic           = "Maximum"
        comparison_operator = "GreaterThanThreshold"
        threshold           = 1000 # 1000 milliseconds (1 second)
        evaluation_periods  = 5
        datapoints_to_alarm = 5
        period              = 60
        dimensions          = { StreamName = stream }
        alarm_description   = "PutRecord maximum latency exceeded 1000ms for 5 consecutive minutes. Investigate producer performance."
        treat_missing_data  = "notBreaching" # Missing data shouldn't trigger
      },
      {
        type                = 1 # Standard metric alarm
        alarm_name          = "[HIGH] Kinesis-${stream}-Low-SubscribeToShard-Success"
        metric_name         = "SubscribeToShard.Success"
        namespace           = "AWS/Kinesis"
        statistic           = "Average"
        comparison_operator = "LessThanThreshold"
        threshold           = 1
        evaluation_periods  = 5
        datapoints_to_alarm = 5
        period              = 300 # 5 minutes
        dimensions = {
          StreamName   = "${stream}",
          ConsumerName = "ReportConsumerApplication-20250730"
        }
        alarm_description  = "SubscribeToShard success rate below 1%. Indicates shard subscription failures. ConsumerName is ReportConsumerApplication-20250730."
        treat_missing_data = "breaching" # Missing data should trigger alarm
      }
    ]
  ])

  ######## Valkey 

  valkey_alarms = [
    {
      type                = 1
      alarm_name          = "[HIGH] Valkey-${local.valkey_cluster_id}-High-Connections-connection count exceeds 200"
      metric_name         = "CurrConnections"
      namespace           = "AWS/ElastiCache"
      statistic           = "Average"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = 200 # Connection count
      evaluation_periods  = 3
      datapoints_to_alarm = 3
      period              = 300
      dimensions          = { clusterId = local.valkey_cluster_id }
      alarm_description   = "Valkey cluster connection count exceeds 200"
      treat_missing_data  = "notBreaching"

    }
  ]



  ecs_service_monitoring_rules = flatten([
    for cluster, services in local.ecs_clusters : [
      for service in services : [
        # Add PendingTaskCount alarm for each service
        {
          type                = 1
          alarm_name          = "[HIGH]${local.environment}-[${cluster}/${service}]-ECS-Pending-Tasks-greater-than-0-for-5-minutes"
          metric_name         = "PendingTaskCount"
          comparison_operator = "GreaterThanThreshold"
          threshold           = "0"
          namespace           = "ECS/ContainerInsights"
          statistic           = "Maximum"
          period              = "60"
          evaluation_periods  = "5"
          datapoints_to_alarm = "5"
          treat_missing_data  = "notBreaching"
          dimensions = {
            ClusterName = "${local.environment}-${cluster}",
            ServiceName = service
          }
          alarm_description = "This metric monitors ECS pending tasks count"
        },
        {
          type                = 1
          alarm_name          = "[HIGH]${local.environment}-[${cluster}/${service}]-ECS-Fargate-CPU-Utilization-greater-than-75-percent-in-5-minutes"
          metric_name         = "CPUUtilization"
          comparison_operator = "GreaterThanOrEqualToThreshold"
          threshold           = "75"
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
          alarm_name          = "[HIGH]${local.environment}-[${cluster}/${service}]-ECS-Fargate-Memory-Utilization-greater-than-75-percent-in-5-minutes"
          metric_name         = "MemoryUtilization"
          comparison_operator = "GreaterThanOrEqualToThreshold"
          threshold           = "75"
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
        alarm_name          = "[HIGH]${local.environment}-EC2-Bastion-CPU-Utilization-greater-than-85-percent-in-5-minutes"
        metric_name         = "CPUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "85"
        namespace           = "AWS/EC2"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "1"
        datapoints_to_alarm = "1"
        treat_missing_data  = "missing"
        dimensions          = { InstanceId = "i-0392f6bf027c863f2" }
        alarm_description   = "This metric monitors EC2 Bastion CPU utilization"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-EC2-Clickhouse-CPU-Utilization-greater-than-90-percent-in-5-minutes"
        metric_name         = "CPUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "90"
        namespace           = "AWS/EC2"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "1"
        datapoints_to_alarm = "1"
        treat_missing_data  = "missing"
        dimensions          = { InstanceId = "i-0a7f05a474d30f822" }
        alarm_description   = "This metric monitors EC2 Clickhouse CPU utilization"
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
        alarm_name          = "[HIGH]${local.environment}-RDS-CPU-Utilization-greater-than-75-percent-in-5-minutes"
        metric_name         = "CPUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "75"
        namespace           = "AWS/RDS"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { DBClusterIdentifier = aws_rds_cluster.prod_asia_main.id }
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
        dimensions          = { DBClusterIdentifier = aws_rds_cluster.prod_asia_main.id }
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
        dimensions          = { DBClusterIdentifier = aws_rds_cluster.prod_asia_main.id }
        alarm_description   = "This metric monitors RDS Database Connections"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-RDS-ACU-Utilization-greater-than-60-percent-in-5-minutes(20250115025026601500000003)"
        metric_name         = "ACUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "60"
        namespace           = "AWS/RDS"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { DBClusterIdentifier = "prod-asia-20250115025026601500000003" }
        alarm_description   = "This metric monitors RDS ACU utilization"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-RDS-ACU-Utilization-greater-than-60-percent-in-5-minutes(20250115025111113300000004)"
        metric_name         = "ACUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "60"
        namespace           = "AWS/RDS"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { DBInstanceIdentifier = "prod-asia-20250115025111113300000004" }
        alarm_description   = "This metric monitors RDS ACU utilization"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-RDS-ACU-Utilization-greater-than-60-percent-in-5-minutes(20250115025111115400000005)"
        metric_name         = "ACUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "60"
        namespace           = "AWS/RDS"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { DBInstanceIdentifier = "prod-asia-reader-20250115025111115400000005" }
        alarm_description   = "This metric monitors RDS ACU utilization"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-RDS-ACU-Utilization-greater-than-60-percent-in-5-minutes(20250804042746538000000001)"
        metric_name         = "ACUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "60"
        namespace           = "AWS/RDS"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { DBInstanceIdentifier = "prod-asia-reader-20250804042746538000000001" }
        alarm_description   = "This metric monitors RDS ACU utilization"
      },
      ############ DynamoDB Metrics ############
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-DynamoDB-Consumed-Read-Capacity-Units-greater-than-75-percent-in-5-minutes"
        metric_name         = "ConsumedReadCapacityUnits"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "75"
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
        alarm_name          = "[HIGH]${local.environment}-DynamoDB-Consumed-Write-Capacity-Units-greater-than-75-percent-in-5-minutes"
        metric_name         = "ConsumedWriteCapacityUnits"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "75"
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
    # local.additional_target_group_alarms,
    local.cassandra_alarms,
    local.target_group_alarms,
    local.kinesis_alarms,
    local.valkey_alarms
  )
}

module "prod_asia_cloudwatch_sns_topic" {
  source = "../../modules/cloudwatch-sns-topic"

  region           = local.region
  environment      = local.environment
  sns_topic_name   = "${local.environment}-sns-topic-for-cloudwatch-alarms"
  LARK_WEBHOOK_URL = "https://botbuilder.larksuite.com/api/trigger-webhook/8738bdee5efaa10bd52453cab0872afa"
}

module "prod_asia_monitoring" {
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
    module.prod_asia_cloudwatch_sns_topic.get_sns_topic_arn
  ]
  ok_actions = [
    module.prod_asia_cloudwatch_sns_topic.get_sns_topic_arn
  ]
}
