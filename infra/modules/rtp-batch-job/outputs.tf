output "job_definition_arn" {
  description = "The Amazon Resource Name of the job definition"
  value       = try(aws_batch_job_definition.this[0].arn, "")
}

output "job_definition_name" {
  description = "The Name of the job definition"
  value       = try(aws_batch_job_definition.this[0].name, "")
}

output "job_queue" {
  description = "Map of job queues created and their associated attributes"
  value       = aws_batch_job_queue.this
}

output "job_definition" {
  description = "Map of job defintions created and their associated attributes"
  value       = aws_batch_job_definition.this
}

output "cwe_rule_name" {
  description = "The cloudwatch rule's prefix name will be used"
  value       = "${local.name}-event"
}
