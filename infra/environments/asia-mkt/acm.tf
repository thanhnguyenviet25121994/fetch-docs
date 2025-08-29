
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
    aws = aws.global
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