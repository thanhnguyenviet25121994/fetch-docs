resource "aws_keyspaces_keyspace" "keyspace" {
  name = "${local.environment}_keyspace"

  replication_specification {
    region_list          = ["ap-southeast-1", "eu-west-1", "sa-east-1"]
    replication_strategy = "MULTI_REGION"
  }
}