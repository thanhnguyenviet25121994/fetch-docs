
module "prod_acm" {
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

resource "cloudflare_record" "prod_acm" {
  count = length(module.prod_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.root.id
  name    = element(module.prod_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.prod_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.prod_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}



module "aw_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.${local.aw_domain}"
  #   subject_alternative_names = [
  #     "*.${var.domain}"
  #   ]

  zone_id = data.cloudflare_zone.aw.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.global
  }

}

resource "cloudflare_record" "aw_acm" {
  count = length(module.aw_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.aw.id
  name    = element(module.aw_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.aw_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.aw_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}






#### PGS ACM for pgs2
module "pgs2_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.0"

  domain_name = "*.pgs.${local.root_domain}"

  zone_id = data.cloudflare_zone.root.id

  wait_for_validation    = true
  validate_certificate   = false
  create_route53_records = false
  validation_method      = "DNS"

  providers = {
    aws = aws.global
  }

}

resource "cloudflare_record" "pgs2_acm" {
  count = length(module.pgs2_acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.root.id
  name    = element(module.pgs2_acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.pgs2_acm.validation_domains, count.index)["resource_record_type"]
  content = trimsuffix(element(module.pgs2_acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}