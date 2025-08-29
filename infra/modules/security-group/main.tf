data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

locals {
  ipv4_cidr_blocks = [
    "173.245.48.0/20",
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "141.101.64.0/18",
    "108.162.192.0/18",
    "190.93.240.0/20",
    "188.114.96.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "162.158.0.0/15",
    "104.16.0.0/13",
    "104.24.0.0/14",
    "172.64.0.0/13",
    "131.0.72.0/22"
  ]
  ipv6_cidr_blocks = [
    "2400:cb00::/32",
    "2606:4700::/32",
    "2803:f800::/32",
    "2405:b500::/32",
    "2405:8100::/32",
    "2a06:98c0::/29",
    "2c0f:f248::/32"
  ]
}

# data "aws_prefix_list" "cloudfront" {
#   filter {
#     name   = "com.amazonaws.global.cloudfront.origin-facing"
#     values = ["pl-5da64334"] # sa-east 1

#   }
# }

# resource "aws_security_group" "allow_cloudfront_http" {
#   name        = "allow-cloudfront-http"
#   description = "Allow HTTP traffic from CloudFront distribution"

#   # Allow inbound HTTP traffic from CloudFront IP ranges
#   ingress {
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
#   }

#   # Optional: Allow outbound traffic to anywhere
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

resource "aws_ec2_managed_prefix_list" "cloudflare_v4" {
  name           = "cloudflare-ips-v4"
  address_family = "IPv4"
  max_entries    = length(local.ipv4_cidr_blocks)

  dynamic "entry" {
    for_each = local.ipv4_cidr_blocks
    content {
      cidr        = entry.value
      description = "Cloudflare IP Range ${entry.key + 1}"
    }
  }

  tags = var.tags
}

resource "aws_ec2_managed_prefix_list" "cloudflare_v6" {
  name           = "cloudflare-ips-v6"
  address_family = "IPv6"
  max_entries    = length(local.ipv6_cidr_blocks)

  dynamic "entry" {
    for_each = local.ipv6_cidr_blocks
    content {
      cidr        = entry.value
      description = "Cloudflare IP Range ${entry.key + 1}"
    }
  }

  tags = var.tags
}

resource "aws_security_group" "allow_cloudflare" {
  name        = "allow_cloudflare"
  description = "Allow HTTP/HTTPS traffic from Cloudflare IPs"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from Cloudflare"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    prefix_list_ids = [
      aws_ec2_managed_prefix_list.cloudflare_v4.id,
      aws_ec2_managed_prefix_list.cloudflare_v6.id
    ]
  }

  ingress {
    description = "HTTPS from Cloudflare"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    prefix_list_ids = [
      aws_ec2_managed_prefix_list.cloudflare_v4.id,
      aws_ec2_managed_prefix_list.cloudflare_v6.id
    ]
  }

  tags = merge(var.tags, {
    Name = "allow_cloudflare"
  })
}

resource "aws_security_group" "allow_cloudfront" {
  name        = "allow_cloudfront"
  description = "Allow HTTP/HTTPS traffic from CloudFront"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from CloudFront"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }

  tags = merge(var.tags, {
    Name = "allow_cloudfront"
  })
}