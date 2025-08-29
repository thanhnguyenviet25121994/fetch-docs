resource "cloudflare_ruleset" "terraform_managed_resource_022015218b404fcd8a0705f414ef5d7c" {
  kind    = "zone"
  name    = "default"
  phase   = "http_request_cache_settings"
  zone_id = "67f6f139efd3c04a32d3757626b4c13a"
  rules {
    action = "set_cache_settings"
    action_parameters {
      cache = false
    }
    description = "By pass cache for config.json and version.json"
    enabled     = true
    expression  = "(http.request.uri.path eq \"/config.json\") or (ends_with(http.request.uri.path, \"/version.json\")) or (starts_with(http.request.uri.path, \"/env-config\")) or (starts_with(http.request.uri.path, \"/static/background\"))"
  }
  rules {
    action = "set_cache_settings"
    action_parameters {
      cache                = true
      origin_cache_control = true
    }
    description = "Cache JSON"
    enabled     = true
    expression  = "(http.request.uri.path.extension eq \"json\")"
  }
  rules {
    action = "set_cache_settings"
    action_parameters {
      cache = true
      edge_ttl {
        default = 2678400
        mode    = "override_origin"
      }
      origin_cache_control = false
    }
    description = "Cache additional Cocos artifacts"
    enabled     = true
    expression  = "(http.request.uri.path.extension eq \"wasm\") or (http.request.uri.path.extension eq \"astc\") or (http.request.uri.path.extension eq \"ttf\") or (http.request.uri.path.extension eq \"cconb\") or (http.request.uri.path.extension eq \"plist\") or (http.request.uri.path.extension eq \"pkm\") or (http.request.uri.path.extension eq \"mp3\") or (http.request.uri.path.extension eq \"m4a\") or (http.request.uri.path.extension eq \"ogg\") or (http.request.uri.path.extension eq \"mjs\") or (http.request.uri.path.extension eq \"png\")"
  }
}

# resource "cloudflare_ruleset" "terraform_managed_resource_6cc71ec9f56540fba1a1466d48a3d8a0" {
#   kind    = "zone"
#   name    = "default"
#   phase   = "http_request_dynamic_redirect"
#   zone_id = "67f6f139efd3c04a32d3757626b4c13a"
# }

resource "cloudflare_ruleset" "terraform_managed_resource_44f50a38ce184f078d4493c03db6a66c" {
  kind    = "zone"
  name    = "default"
  phase   = "http_request_transform"
  zone_id = "67f6f139efd3c04a32d3757626b4c13a"
  rules {
    action = "rewrite"
    action_parameters {
      uri {
        path {
          expression = "wildcard_replace(http.request.uri, r\"*.rg-lgna.com/*\", r\"/$${1}/$${2}\")"
        }
      }
    }
    description = "fortune-dragon-2 (Cloud Connector testing)"
    enabled     = true
    expression  = "(http.host eq \"fortune-dragon-2.rg-lgna.com\" and not http.request.uri.path in {\"/config.json\" \"env-config.js\"})"
  }
}

resource "cloudflare_ruleset" "terraform_managed_resource_812cc1f85ba343a5a79c7d8da9fb6d93" {
  kind    = "zone"
  name    = "default"
  phase   = "http_response_compression"
  zone_id = "67f6f139efd3c04a32d3757626b4c13a"
  rules {
    action = "compress_response"
    action_parameters {
      algorithms {
        name = "zstd"
      }
      algorithms {
        name = "brotli"
      }
      algorithms {
        name = "gzip"
      }
    }
    description = "Experimental"
    enabled     = true
    expression  = "(http.request.uri.path.extension eq \"astc\") or (http.request.uri.path.extension eq \"wasm\") or (http.request.uri.path.extension eq \"ttf\") or (http.request.uri.path.extension eq \"cconb\") or (http.request.uri.path.extension eq \"plist\") or (http.request.uri.path.extension eq \"pkm\") or (http.request.uri.path.extension eq \"png\")"
  }
}

resource "cloudflare_ruleset" "terraform_managed_resource_04016c3ef69044b18ee11fa96dd9836f" {
  kind    = "zone"
  name    = "default"
  phase   = "http_response_headers_transform"
  zone_id = "67f6f139efd3c04a32d3757626b4c13a"
  rules {
    action = "rewrite"
    action_parameters {
      headers {
        name      = "Access-Control-Allow-Methods"
        operation = "set"
        value     = "GET, POST, OPTIONS"
      }
      headers {
        name      = "Access-Control-Allow-Origin"
        operation = "set"
        value     = "*"
      }
    }
    description = "CORS"
    enabled     = true
    expression  = "(starts_with(http.host, \"common-assets\")) or (starts_with(http.host, \"api\"))"
  }
  rules {
    action = "rewrite"
    action_parameters {
      headers {
        name      = "Referrer-Policy"
        operation = "set"
        value     = "unsafe-url"
      }
    }
    description = "Always Forward Referrer"
    enabled     = false
    expression  = "true"
  }
}