output "cloudflare_sg_id" {
  description = "ID of the Allow Cloudflare security group"
  value       = aws_security_group.allow_cloudflare.id
}

output "cloudfront_sg_id" {
  description = "ID of the Allow CloudFront security group"
  value       = aws_security_group.allow_cloudfront.id
}