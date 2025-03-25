
### Environment 

variable "CLUSTER_NAME" {
  type = string
}

resource "vault_mount" "kv" {
# path includes cluster name
  path        = "${var.CLUSTER_NAME}-kv"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_backend_v2" "example" {
  mount                = vault_mount.kv.path
  max_versions         = 15
  cas_required         = false
}


### Variables


### Globals


variable "DOMAIN_NAME" {
  type = string
}

variable "TIMEZONE" {
    type = string
}

variable "INGRESS_IP" {
    type = string
}

variable "TRUENAS_IP" {
    type = string
}

variable "EMAIL_ADDRESS" {
    type = string
}

### Proxmox 

variable "PROXMOX_IP" {
    type = string
}

### TrueNAS

variable "TRUENAS_MEDIA_SHARE_PATH" {
    type = string
}

variable "TRUENAS_ISCSI_SHARE_PATH" {
    type = string
}

variable "TRUENAS_API_KEY" {
    type = string
}

### S3 backups

variable "S3_ENDPOINT" {
    type = string
}

variable "S3_REGION" {
    type = string
}


### Cloudnative PG

variable "CLOUDNATIVE_S3_BUCKET" {
    type = string
}

variable "CLOUDNATIVE_S3_KEY" {
    type = string
}

variable "CLOUDNATIVE_S3_KEY_ID" {
    type = string
}

### Authentik

variable "AUTHENTIK_BOOTSTRAP_PASSWORD" {
    type = string
}

variable "AUTHENTIK_BOOTSTRAP_EMAIL" {
    type = string
}

### Cloudflare api token

variable "CLOUDFLARE_API_TOKEN" {
    type = string
}

variable "CLOUDFLARE_ARGO_TUNNEL_CREDS" {
    type = string
}

variable "CLOUDFLARE_ARGO_TUNNEL_ID" {
  
}

### private internet access
variable "PRIVATE_INTERNET_ACCESS_USERNAME" {
    type = string
}

variable "PRIVATE_INTERNET_ACCESS_PASSWORD" {
    type = string
}

### discord webhooks
variable "DISCORD_MEDIA_WEBHOOK" {
    type = string
}

variable "DISCORD_NOTIFICATIONS_WEBHOOK" {
    type = string
}

## Secrets

resource "vault_kv_secret_v2" "cluster-settings" {
    mount    = vault_mount.kv.path
    name    = "cluster-settings"
    data_json = jsonencode({
        "domain_name" = var.DOMAIN_NAME
        "timezone" = var.TIMEZONE
        "truenas_ip" = var.TRUENAS_IP
        "ingress_ip" = var.INGRESS_IP
        "email_address" = var.EMAIL_ADDRESS
    })
}

resource "vault_kv_secret_v2" "s3" {
    mount    = vault_mount.kv.path
    name    = "s3"
    data_json = jsonencode({
        "s3_endpoint" = var.S3_ENDPOINT
        "s3_region" = var.S3_REGION
    })
}

resource "vault_kv_secret_v2" "cloudnative_s3" {
    mount    = vault_mount.kv.path
    name    = "cloudnative_s3"
    data_json = jsonencode({
        "s3_bucket" = var.CLOUDNATIVE_S3_BUCKET
        "s3_key" = var.CLOUDNATIVE_S3_KEY
        "s3_key_id" = var.CLOUDNATIVE_S3_KEY_ID
    })
}

resource "random_password" "authentik_secret_key" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "random_password" "authentik_bootstrap_token" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "vault_kv_secret_v2" "authentik" {
    mount    = vault_mount.kv.path
    name    = "authentik"
    data_json = jsonencode({
        "bootstrap_password" = var.AUTHENTIK_BOOTSTRAP_PASSWORD
        "bootstrap_email" = var.AUTHENTIK_BOOTSTRAP_EMAIL
        "bootstrap_token" = random_password.authentik_bootstrap_token.result
        "secret_key" = random_password.authentik_secret_key.result
    })
}

resource "vault_kv_secret_v2" "cloudflare" {
    mount    = vault_mount.kv.path
    name    = "cloudflare"
    data_json = jsonencode({
        "api_token" = var.CLOUDFLARE_API_TOKEN
        "argo_tunnel_creds" = var.CLOUDFLARE_ARGO_TUNNEL_CREDS
        "argo_tunnel_id" = var.CLOUDFLARE_ARGO_TUNNEL_ID
    })
}

resource "vault_kv_secret_v2" "truenas" {
    mount    = vault_mount.kv.path
    name    = "truenas"
    data_json = jsonencode({
        "api_key" = var.TRUENAS_API_KEY
        "media_share_path" = var.TRUENAS_MEDIA_SHARE_PATH
        "iscsi_share_path" = var.TRUENAS_ISCSI_SHARE_PATH
    })
}

resource "vault_kv_secret_v2" "discord" {
    mount    = vault_mount.kv.path
    name    = "discord"
    data_json = jsonencode({
        "discord_media_webhook" = var.DISCORD_MEDIA_WEBHOOK
        "discord_notifications_webhook" = var.DISCORD_NOTIFICATIONS_WEBHOOK
    })
}

resource "vault_kv_secret_v2" "private_internet_access" {
    mount    = vault_mount.kv.path
    name    = "private_internet_access"
    data_json = jsonencode({
        "OPENVPN_USER" = var.PRIVATE_INTERNET_ACCESS_USERNAME
        "OPENVPN_PASSWORD" = var.PRIVATE_INTERNET_ACCESS_PASSWORD
        "VPN_SERVICE_PROVIDER" = "private internet access"
    })
}


### Randomly generated secrets


resource "random_password" "gluetun_apikey" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "vault_kv_secret_v2" "gluetun_apikey" {
    mount    = vault_mount.kv.path
    name    = "gluetun_apikey"
    data_json = jsonencode({
        "GLUETUN_CONTROL_SERVER_API_KEY" = random_password.gluetun_apikey.result
    })
}

resource "random_password" "sonarr_apikey" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "vault_kv_secret_v2" "sonarr_apikey" {
    mount    = vault_mount.kv.path
    name    = "sonarr_apikey"
    data_json = jsonencode({
        "SONARR__AUTH__APIKEY" = random_password.sonarr_apikey.result
    })
}

resource "random_password" "radarr_apikey" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "vault_kv_secret_v2" "radarr_apikey" {
    mount    = vault_mount.kv.path
    name    = "radarr_apikey"
    data_json = jsonencode({
        "RADARR__AUTH__APIKEY" = random_password.radarr_apikey.result
    })
}

resource "random_password" "prowlarr_apikey" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "vault_kv_secret_v2" "prowlarr_apikey" {
    mount    = vault_mount.kv.path
    name    = "prowlarr_apikey"
    data_json = jsonencode({
        "PROWLARR__AUTH__APIKEY" = random_password.prowlarr_apikey.result
    })
}

resource "random_password" "grafana_oauth_client_secret" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "random_password" "grafana_oauth_client_id" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "vault_kv_secret_v2" "grafana_oauth" {
    mount    = vault_mount.kv.path
    name    = "grafana_oauth"
    data_json = jsonencode({
        "client_id" = random_password.grafana_oauth_client_id.result
        "client_secret" = random_password.grafana_oauth_client_secret.result
    })
}

resource "random_password" "proxmox_oauth_client_secret" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "random_password" "proxmox_oauth_client_id" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "vault_kv_secret_v2" "proxmox" {
    mount    = vault_mount.kv.path
    name    = "proxmox"
    data_json = jsonencode({
        "client_id" = random_password.proxmox_oauth_client_id.result
        "client_secret" = random_password.proxmox_oauth_client_secret.result
        "proxmox_ip" = var.PROXMOX_IP
    })
}
