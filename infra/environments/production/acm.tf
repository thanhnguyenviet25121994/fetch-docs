
module "pgs_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.${local.pgs_domain}"
  #   subject_alternative_names = [
  #     "*.${var.domain}"
  #   ]

  zone_id = data.cloudflare_zone.pgs.id

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

  zone_id = data.cloudflare_zone.pgs.id
  name    = element(module.pgs_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.pgs_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.pgs_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}




locals {
  pxplaygaming_domain = "pxplaygaming.com"
  pxplay88_domain     = "pxplay88.com"
  hacksaw_domain      = "hacksawproduction.com"

}

data "cloudflare_zone" "pxplaygaming" {
  name = local.pxplaygaming_domain
}

data "cloudflare_zone" "pxplay88" {
  name = local.pxplay88_domain
}

data "cloudflare_zone" "hacksaw" {
  name = local.hacksaw_domain
}


data "cloudflare_zone" "pp" {
  name = "pragmaticpplay.com"
}

###########
## sbox lobby alias

module "pxplaygaming_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = local.pxplaygaming_domain
  subject_alternative_names = [
    "*.${local.pxplaygaming_domain}"
  ]

  zone_id = data.cloudflare_zone.pxplaygaming.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.us-east-1
  }

}

resource "cloudflare_record" "pxplaygaming_acm" {
  count = length(module.pxplaygaming_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.pxplaygaming.id
  name    = element(module.pxplaygaming_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.pxplaygaming_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.pxplaygaming_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}



###########
## prod lobby alias

module "pxplay88_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = local.pxplay88_domain
  subject_alternative_names = [
    "*.${local.pxplay88_domain}"
  ]

  zone_id = data.cloudflare_zone.pxplay88.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.us-east-1
  }

}

resource "cloudflare_record" "pxplay88_acm" {
  count = length(module.pxplay88_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.pxplay88.id
  name    = element(module.pxplay88_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.pxplay88_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.pxplay88_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}






###########
## hacksaw acm

module "hacksaw_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = local.hacksaw_domain
  subject_alternative_names = [
    "*.${local.hacksaw_domain}"
  ]

  zone_id = data.cloudflare_zone.hacksaw.id

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

  zone_id = data.cloudflare_zone.hacksaw.id
  name    = element(module.hacksaw_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.hacksaw_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.hacksaw_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}




#######
## acm pp
###########
## hacksaw acm

module "pp_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.sandbox.pragmaticpplay.com"

  zone_id = data.cloudflare_zone.pp.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.us-east-1
  }

}

resource "cloudflare_record" "pp_acm" {
  count = length(module.pp_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.pp.id
  name    = element(module.pp_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.pp_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.pp_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}






module "mkt_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.mkt.${local.root_domain}"
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

resource "cloudflare_record" "mkt_acm" {
  count = length(module.mkt_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.root.id
  name    = element(module.mkt_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.mkt_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.mkt_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}