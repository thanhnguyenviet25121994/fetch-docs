############
### aws-data
###########
output "aws_region" {
  description = "Details about selected AWS region"
  value       = module.aws-data.aws_region
}

output "available_aws_availability_zones_names" {
  description = "A list of the Availability Zone names available to the account"
  value       = module.aws-data.available_aws_availability_zones_names
}

output "available_aws_availability_zones_zone_ids" {
  description = "A list of the Availability Zone IDs available to the account"
  value       = module.aws-data.available_aws_availability_zones_zone_ids
}

output "aws_ami_ids" {
  description = "A list of AMI IDs"
  value       = module.aws-data.aws_ami_ids
}