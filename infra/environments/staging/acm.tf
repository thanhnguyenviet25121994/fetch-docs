
module "pgs_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.pgs.sandbox.${local.root_domain}"
  #   subject_alternative_names = [
  #     "*.${var.domain}"
  #   ]

  zone_id = data.cloudflare_zone.root.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.us-east-1
  }

}

resource "cloudflare_record" "pgs_acm" {
  count = length(module.pgs_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.root.id
  name    = element(module.pgs_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.pgs_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.pgs_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}




########################
### hacksaw gaming
########################



module "hacksaw_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.hacksaw.sandbox.${local.root_domain}"
  #   subject_alternative_names = [
  #     "*.${var.domain}"
  #   ]

  zone_id = data.cloudflare_zone.root.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.us-east-1
  }

}

resource "cloudflare_record" "hacksaw_acm" {
  count = length(module.hacksaw_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.root.id
  name    = element(module.hacksaw_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.hacksaw_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.hacksaw_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}



locals {

  mx712_domain = "mx712.com"
  mx913_domain = "mx913.com"
  mx923_domain = "mx923.com"
  mx953_domain = "mx953.com"
  mx973_domain = "mx973.com"
}
data "cloudflare_zone" "mx712" {
  name = "mx712.com"
}

module "mx712_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.${local.mx712_domain}"
  subject_alternative_names = [
    "${local.mx712_domain}"
  ]

  zone_id = data.cloudflare_zone.mx712.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.us-east-1
  }

}

resource "cloudflare_record" "mx712_acm" {
  count = length(module.mx712_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.mx712.id
  name    = element(module.mx712_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.mx712_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.mx712_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}




# MX913.COM
data "cloudflare_zone" "mx913" {
  name = "mx913.com"
}

module "mx913_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.mx913.com"
  subject_alternative_names = [
    "${local.mx913_domain}"
  ]
  zone_id = data.cloudflare_zone.mx913.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.us-east-1
  }
}

resource "cloudflare_record" "mx913_acm" {
  count = length(module.mx913_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.mx913.id
  name    = element(module.mx913_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.mx913_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.mx913_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}

# MX923.COM
data "cloudflare_zone" "mx923" {
  name = "mx923.com"
}

module "mx923_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.mx923.com"
  subject_alternative_names = [
    "${local.mx923_domain}"
  ]
  zone_id = data.cloudflare_zone.mx923.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.us-east-1
  }
}

resource "cloudflare_record" "mx923_acm" {
  count = length(module.mx923_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.mx923.id
  name    = element(module.mx923_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.mx923_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.mx923_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}

# MX953.COM
data "cloudflare_zone" "mx953" {
  name = "mx953.com"
}

module "mx953_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.mx953.com"
  subject_alternative_names = [
    "${local.mx953_domain}"
  ]
  zone_id = data.cloudflare_zone.mx953.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.us-east-1
  }
}

resource "cloudflare_record" "mx953_acm" {
  count = length(module.mx953_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.mx953.id
  name    = element(module.mx953_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.mx953_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.mx953_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}

# MX973.COM
data "cloudflare_zone" "mx973" {
  name = "mx973.com"
}

module "mx973_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.mx973.com"
  subject_alternative_names = [
    "${local.mx973_domain}"
  ]
  zone_id = data.cloudflare_zone.mx973.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.us-east-1
  }
}

resource "cloudflare_record" "mx973_acm" {
  count = length(module.mx973_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.mx973.id
  name    = element(module.mx973_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.mx973_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.mx973_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}




module "acewin_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.acewin.sandbox.${local.root_domain}"
  #   subject_alternative_names = [
  #     "*.${var.domain}"
  #   ]

  zone_id = data.cloudflare_zone.root.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.us-east-1
  }

}

resource "cloudflare_record" "acewin_acm" {
  count = length(module.acewin_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.root.id
  name    = element(module.acewin_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.acewin_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.acewin_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}
