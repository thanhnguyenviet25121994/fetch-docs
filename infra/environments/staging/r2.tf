resource "cloudflare_r2_bucket" "casual_mx" {
  account_id = "9ebe0152fa75ef3a96772d19b1f28644"
  name       = "casual-mx"
  location   = "APAC"
}