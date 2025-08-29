locals {
  alb_name            = regex("loadbalancer/(.+)", aws_lb.prd_eu.arn)[0]
  cache_cluster_id    = "${local.environment}-srv-game-client"
  dynamodb_table_name = "${local.environment}_bet_results"

  ecs_clusters = {
    "srv-game-client"      = ["srv-game-client"],
    "srv-pp-adaptor"       = ["srv-pp-adaptor"],
    "srv-entity"           = ["srv-entity"],
    "portal-replay"        = ["portal-replay"],
    "share-ui-game-client" = ["share-ui-game-client"],
    "srv-static-router"    = ["srv-static-router"],
    "operator-demo"        = ["operator-demo"],

  }

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
        alarm_name          = "[HIGH]${local.environment}-EC2-Bastion-CPU-Utilization-greater-than-80-percent-in-5-minutes"
        metric_name         = "CPUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "80"
        namespace           = "AWS/EC2"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "1"
        datapoints_to_alarm = "1"
        treat_missing_data  = "missing"
        dimensions          = { InstanceId = "i-080b35ca39580a7a2" }
        alarm_description   = "This metric monitors EC2 Bastion CPU utilization"
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
      {
        type                = 2
        alarm_name          = "[HIGH]${local.environment}-ALB-Target-HTTP-5XX-Error-Count-greater-than-100-in-5-minutes(srv-game-client)"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = 100
        evaluation_periods  = 5
        datapoints_to_alarm = 5
        treat_missing_data  = "notBreaching"
        period              = 60
        alarm_description   = "This metric monitors ALB Target HTTP 5XX Error Count for srv-game-client"
        namespace           = "AWS/ApplicationELB"
        statistic           = "Sum"
        metric_query = [
          {
            id          = "e1"
            expression  = "SUM([m1])"
            label       = "${local.environment}-srv-game-client"
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
                TargetGroup  = "targetgroup/${local.environment}-srv-game-client/9b2b1d1c0f906322"
                LoadBalancer = "${local.alb_name}"
              }
            },
            label       = "HTTPCode_Target_5XX_Count",
            return_data = false
          },
        ]
      },
      {
        type                = 2
        alarm_name          = "[HIGH]${local.environment}-ALB-Target-HTTP-5XX-Error-Count-greater-than-100-in-5-minutes(srv-pp-adaptor)"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = 100
        evaluation_periods  = 5
        datapoints_to_alarm = 5
        treat_missing_data  = "notBreaching"
        period              = 60
        alarm_description   = "This metric monitors ALB Target HTTP 5XX Error Count for srv-pp-adaptor"
        namespace           = "AWS/ApplicationELB"
        statistic           = "Sum"
        metric_query = [
          {
            id          = "e1"
            expression  = "SUM([m1])"
            label       = "${local.environment}-srv-pp-adaptor"
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
                TargetGroup  = "targetgroup/${local.environment}-srv-pp-adaptor/366846d2eda261e0"
                LoadBalancer = "${local.alb_name}"
              }
            },
            label       = "HTTPCode_Target_5XX_Count",
            return_data = false
          },
        ]
      },
      #   {
      #     type                = 2
      #     alarm_name          = "[HIGH]${local.environment}-ALB-Target-HTTP-5XX-Error-Count-greater-than-100-in-5-minutes(operator-demo)"
      #     comparison_operator = "GreaterThanOrEqualToThreshold"
      #     threshold           = 100
      #     evaluation_periods  = 5
      #     datapoints_to_alarm = 5
      #     treat_missing_data  = "notBreaching"
      #     period              = 60
      #     alarm_description   = "This metric monitors ALB Target HTTP 5XX Error Count for operator-demo"
      #     namespace           = "AWS/ApplicationELB"
      #     statistic           = "Sum"
      #     metric_query = [
      #       {
      #         id          = "e1"
      #         expression  = "SUM([m1])"
      #         label       = "${local.environment}-operator-demo"
      #         return_data = true
      #       },
      #       {
      #         id = "m1"
      #         metric = {
      #           metric_name = "HTTPCode_Target_5XX_Count"
      #           namespace   = "AWS/ApplicationELB"
      #           period      = 60
      #           stat        = "Sum"
      #           unit        = "Count"
      #           dimensions = {
      #             TargetGroup  = "targetgroup/${local.environment}-operator-demo/9bf3c328e1af40a1"
      #             LoadBalancer = "${local.alb_name}"
      #           }
      #         },
      #         label       = "HTTPCode_Target_5XX_Count",
      #         return_data = false
      #       }
      #     ]
      #   },

      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-RDS-ACU-Utilization-greater-than-40-percent-in-5-minutes(20241118084544899900000003)"
        metric_name         = "ACUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "40"
        namespace           = "AWS/RDS"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { DBClusterIdentifier = "prd-eu-20241118084544899900000003" }
        alarm_description   = "This metric monitors RDS ACU utilization"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-RDS-ACU-Utilization-greater-than-40-percent-in-5-minutes(20241118084638640800000004)"
        metric_name         = "ACUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "40"
        namespace           = "AWS/RDS"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { DBInstanceIdentifier = "prd-eu-reader-20241118084638640800000004" }
        alarm_description   = "This metric monitors RDS ACU utilization"
      },
      {
        type                = 1
        alarm_name          = "[HIGH]${local.environment}-RDS-ACU-Utilization-greater-than-40-percent-in-5-minutes(20241118084638643500000005)"
        metric_name         = "ACUUtilization"
        comparison_operator = "GreaterThanOrEqualToThreshold"
        threshold           = "40"
        namespace           = "AWS/RDS"
        statistic           = "Average"
        period              = "60"
        evaluation_periods  = "5"
        datapoints_to_alarm = "5"
        treat_missing_data  = "missing"
        dimensions          = { DBInstanceIdentifier = "prd-eu-20241118084638643500000005" }
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
    local.ecs_service_monitoring_rules
  )
}

module "prd_eu_cloudwatch_sns_topic" {
  source = "../../modules/cloudwatch-sns-topic"

  region           = local.region
  environment      = local.environment
  sns_topic_name   = "${local.environment}-sns-topic-for-cloudwatch-alarms"
  LARK_WEBHOOK_URL = "https://botbuilder.larksuite.com/api/trigger-webhook/6fbf79b6fc3ccae4d6b2a261679a0732"
}

module "prd_eu_monitoring" {
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
    module.prd_eu_cloudwatch_sns_topic.get_sns_topic_arn
  ]
  ok_actions = [
    module.prd_eu_cloudwatch_sns_topic.get_sns_topic_arn
  ]
}
