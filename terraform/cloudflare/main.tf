terraform {

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.35.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }
  }
}

data "sops_file" "cloudflare_secrets" {
  source_file = "secret.sops.yaml"
}

provider "cloudflare" {
  email   = data.sops_file.cloudflare_secrets.data["cloudflare_email"]
  api_key = data.sops_file.cloudflare_secrets.data["cloudflare_apikey"]
}

data "cloudflare_zones" "domain" {
  filter {
    name = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  }
}

resource "cloudflare_zone_settings_override" "cloudflare_settings" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  settings {
    ssl                      = "strict"
    always_use_https         = "on"
    min_tls_version          = "1.2"
    opportunistic_encryption = "on"
    tls_1_3                  = "zrt"
    automatic_https_rewrites = "on"
    universal_ssl            = "on"
    browser_check            = "on"
    challenge_ttl            = 1800
    privacy_pass             = "on"
    security_level           = "medium"
    brotli                   = "on"
    minify {
      css  = "on"
      js   = "on"
      html = "on"
    }
    rocket_loader       = "on"
    always_online       = "off"
    development_mode    = "off"
    http3               = "on"
    zero_rtt            = "on"
    ipv6                = "on"
    websockets          = "on"
    opportunistic_onion = "on"
    pseudo_ipv4         = "off"
    ip_geolocation      = "on"
    email_obfuscation   = "on"
    server_side_exclude = "on"
    hotlink_protection  = "off"
    security_header {
      enabled = false
    }
  }
}

data "http" "ipv4" {
  url = "http://ipv4.icanhazip.com"
}

resource "cloudflare_record" "ipv4" {
  name    = "ipv4"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = chomp(data.http.ipv4.response_body)
  proxied = true
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "proton_txt" {
  name    = "@"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "protonmail-verification=6a918468ef518bcb6c85ce9fd7c859459ddaf4a1"
  proxied = false
  type    = "TXT"
  ttl     = 1
}

resource "cloudflare_record" "proton_mx_1" {
  name     = "@"
  zone_id  = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value    = "mail.protonmail.ch"
  priority = 10
  proxied  = false
  type     = "MX"
  ttl      = 1
}

resource "cloudflare_record" "proton_mx_2" {
  name     = "@"
  zone_id  = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value    = "mailsec.protonmail.ch"
  priority = 20
  proxied  = false
  type     = "MX"
  ttl      = 1
}

resource "cloudflare_record" "proton_spf" {
  name    = "@"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "v=spf1 include:_spf.protonmail.ch mx ~all"
  proxied = false
  type    = "TXT"
  ttl     = 1
}
resource "cloudflare_record" "proton_dkim_1" {
  name    = "protonmail._domainkey"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "protonmail.domainkey.d4d7wdsstkb7btpnkdasjdbdzpxeoydoa4qrvij3wnzwpez4wq5yq.domains.proton.ch"
  proxied = false
  type    = "CNAME"
  ttl     = 1
}
resource "cloudflare_record" "proton_dkim_2" {
  name    = "protonmail2._domainkey"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "protonmail2.domainkey.d4d7wdsstkb7btpnkdasjdbdzpxeoydoa4qrvij3wnzwpez4wq5yq.domains.proton.ch"
  proxied = false
  type    = "CNAME"
  ttl     = 1
}
resource "cloudflare_record" "proton_dkim_3" {
  name    = "protonmail3._domainkey"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "protonmail3.domainkey.d4d7wdsstkb7btpnkdasjdbdzpxeoydoa4qrvij3wnzwpez4wq5yq.domains.proton.ch"
  proxied = false
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "proton_dmarc" {
  name    = "_dmarc"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "v=DMARC1; p=none"
  proxied = false
  type    = "TXT"
  ttl     = 1
}

resource "cloudflare_record" "root_github_pages_1" {
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "185.199.108.153"
  proxied = false
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "root_github_pages_2" {
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "185.199.109.153"
  proxied = false
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "root_github_pages_3" {
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "185.199.110.153"
  proxied = false
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "root_github_pages_4" {
  name    = data.sops_file.cloudflare_secrets.data["cloudflare_domain"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "185.199.111.153"
  proxied = false
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "www_github_pages" {
  name    = "www"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "turnrye.github.io"
  proxied = false
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "nas" {
  name    = "nas"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = chomp(data.http.ipv4.response_body)
  proxied = false
  type    = "A"
  ttl     = 1
}