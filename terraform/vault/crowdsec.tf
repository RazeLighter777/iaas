### CrowdSec

# Per the CrowdSec helm chart: csLapiSecret must be >64 chars and
# registrationToken must be >48 chars.
resource "random_password" "crowdsec_cs_lapi_secret" {
  length  = 80
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "crowdsec_registration_token" {
  length  = 64
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "crowdsec_db_password" {
  length  = 32
  special = true
  numeric = true
  upper   = true
}

variable "CROWDSEC_CONSOLE_ENROLL_KEY" {
  type        = string
  description = "Enrollment key from app.crowdsec.net (Settings -> Engines -> Add). Used by LAPI to register with the CrowdSec console on first boot."
  sensitive   = true
}

variable "CF_ACCOUNT_ID" {
  type        = string
  description = "Cloudflare account ID that owns the domain zone. Found at dash.cloudflare.com under the Overview pane."
}

variable "CF_ZONE_ID" {
  type        = string
  description = "Cloudflare zone ID for the domain (e.g. prizrak.me). Found at dash.cloudflare.com under the Overview pane of the zone."
}

variable "CF_WORKERS_BOUNCER_TOKEN" {
  type        = string
  description = <<-EOT
    Cloudflare API token with the following scopes (Account-scoped):
      Account / Workers Scripts:Edit
      Account / Workers KV Storage:Edit
      Account / Workers Routes:Edit
      Account / Account Settings:Read
      Zone   / Zone Settings:Edit (for the target zone only)
      Zone   / Workers Routes:Edit
      Zone   / Turnstile:Edit
    Create at dash.cloudflare.com/profile/api-tokens.
  EOT
  sensitive   = true
}

resource "vault_kv_secret_v2" "crowdsec" {
  mount = vault_mount.kv.path
  name  = "crowdsec"
  data_json = jsonencode({
    db_password              = random_password.crowdsec_db_password.result
    cs_lapi_secret           = random_password.crowdsec_cs_lapi_secret.result
    registration_token       = random_password.crowdsec_registration_token.result
    console_enroll_key       = var.CROWDSEC_CONSOLE_ENROLL_KEY
    cf_account_id            = var.CF_ACCOUNT_ID
    cf_zone_id               = var.CF_ZONE_ID
    cf_workers_bouncer_token = var.CF_WORKERS_BOUNCER_TOKEN
  })
}
