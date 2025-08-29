terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

variable "cloudfront_distribution_domain_name" {
  type = string
}

variable "app_name" {
  type = string
}

variable "app_env" {
  type = string
}

variable "domain" {
  type = string
}

variable "api_url" {
  type = string
}

variable "assets_url" {
  type = string
}

locals {
  tld = regex("[a-z-_]*.[a-z-_]*$", var.domain)
}

data "cloudflare_zone" "root" {
  name = local.tld
}

resource "aws_s3_bucket" "this" {
  bucket = var.domain

  tags = {
    Name        = var.domain
    Environment = var.app_env
  }
}

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.s3_allow_public_access.json
}

data "aws_iam_policy_document" "s3_allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }

  depends_on = [
    aws_s3_bucket_public_access_block.public
  ]
}

resource "cloudflare_record" "this" {
  zone_id = data.cloudflare_zone.root.id
  name    = var.domain
  value   = var.cloudfront_distribution_domain_name
  type    = "CNAME"
  proxied = true
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.this.bucket
  key    = "config.json"

  content_type = "application/json"
  content = jsonencode({
    envURL          = var.api_url
    commonassetsURL = var.assets_url
  })
}

resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.this.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
