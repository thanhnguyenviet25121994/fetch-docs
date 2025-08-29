
module "pgs_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.pgs.dev.${local.root_domain}"
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

  domain_name = "*.hacksaw.dev.${local.root_domain}"
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



### portal lobby pp dev


module "pp_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.pp.dev.${local.root_domain}"
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

resource "cloudflare_record" "pp_acm" {
  count = length(module.pp_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.root.id
  name    = element(module.pp_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.pp_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.pp_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}




#######
## revenge-games.com

module "revenge_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.${local.root_domain}"
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

resource "cloudflare_record" "revenge_acm" {
  count = length(module.revenge_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.root.id
  name    = element(module.revenge_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.revenge_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.revenge_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}



########################
### acewin gaming
########################



module "acewin_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.acewin.dev.${local.root_domain}"
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





#######
## internal.revenge-games.com

module "rginternal_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.internal.${local.root_domain}"
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

resource "cloudflare_record" "rginternal_acm" {
  count = length(module.rginternal_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.root.id
  name    = element(module.rginternal_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.rginternal_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.rginternal_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}