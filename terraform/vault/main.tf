
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

resource "vault_kv_secret_v2" "globals" {
    mount    = vault_mount.kv.path
    name    = "globals"
    data_json = jsonencode({
        "domain_name" = var.DOMAIN_NAME
        "timezone" = var.TIMEZONE
        "truenas_ip" = var.TRUENAS_IP
        "ingress_ip" = var.INGRESS_IP
    })
}

resource "vault_kv_secret_v2" "s3" {
    mount    = vault_mount.kv.path
    name    = "s3"
    data_json = jsonencode({
        "endpoint" = var.S3_ENDPOINT
        "region" = var.S3_REGION
    })
}

resource "vault_kv_secret_v2" "cloudnative_s3" {
    mount    = vault_mount.kv.path
    name    = "cloudnative"
    data_json = jsonencode({
        "s3_bucket" = var.CLOUDNATIVE_S3_BUCKET
        "s3_key" = var.CLOUDNATIVE_S3_KEY
        "s3_key_id" = var.CLOUDNATIVE_S3_KEY_ID
    })
}

resource "vault_kv_secret_v2" "authentik" {
    mount    = vault_mount.kv.path
    name    = "authentik"
    data_json = jsonencode({
        "bootstrap_password" = var.AUTHENTIK_BOOTSTRAP_PASSWORD
        "bootstrap_email" = var.AUTHENTIK_BOOTSTRAP_EMAIL
    })
}

resource "vault_kv_secret_v2" "cloudflare" {
    mount    = vault_mount.kv.path
    name    = "cloudflare"
    data_json = jsonencode({
        "api_token" = var.CLOUDFLARE_API_TOKEN
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
        "media_webhook" = var.DISCORD_MEDIA_WEBHOOK
        "notifications_webhook" = var.DISCORD_NOTIFICATIONS_WEBHOOK
    })
}

resource "vault_kv_secret_v2" "private_internet_access" {
    mount    = vault_mount.kv.path
    name    = "private_internet_access"
    data_json = jsonencode({
        "username" = var.PRIVATE_INTERNET_ACCESS_USERNAME
        "password" = var.PRIVATE_INTERNET_ACCESS_PASSWORD
    })
}