resource "aws_keyspaces_keyspace" "keyspace" {
  name = "${local.environment}_keyspace"
}