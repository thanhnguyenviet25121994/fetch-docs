
module "prd_acm" {
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
    aws = aws.global
  }

}

resource "cloudflare_record" "prd_acm" {
  count = length(module.prd_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.root.id
  name    = element(module.prd_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.prd_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.prd_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}



########################################
# pgs
########################################



module "pgs_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.pgs.${local.root_domain}"
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




########################################
# pgs-eu
########################################



module "pgs_eu_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.eu.${local.pgs_dns}"
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

resource "cloudflare_record" "pgs_eu_acm" {
  count = length(module.pgs_eu_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.pgs.id
  name    = element(module.pgs_eu_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.pgs_eu_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.pgs_eu_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}