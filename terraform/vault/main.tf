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

variable "HOMEASSISTANT_IP" {
    type = string
}

variable "WG_EASY_IP" {
    type = string
}

variable "EMQX_IP" {
    type = string
}

variable "MINECRAFT_IP" {
    type = string
}

variable "EMAIL_ADDRESS" {
    type = string
}

### IRC 
variable "IRC_USERNAME" {
    type = string
}

### S3 backups

variable "S3_ENDPOINT" {
    type = string
}

variable "S3_REGION" {
    type = string
}

### Cameras


variable "FRIGATE_CAMERA_USERNAME" {
    type = string
}

variable "FRIGATE_CAMERA_PASSWORD" {
    type = string
}

variable "FRIGATE_LIBRARY_CAMERA_IP" {
    type = string
}

variable "FRIGATE_CAT_ROOM_CAMERA_IP" {
    type = string
}

variable "FRIGATE_LIBRARY_CAMERA_UID" {
    type = string
}

variable "FRIGATE_CAT_ROOM_CAMERA_UID" {
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
### NFS MOUNT
variable "NFS_SERVER_IP" {
    type = string
}

### OMADA CONTROLLER IP
variable "OMADA_CONTROLLER_IP" {
    type = string
}

variable "NFS_PATH" {
    type = string
}

### Emqx

variable "EMQX_USERNAME" {
    type = string
}

variable "EMQX_PASSWORD" {
    type = string
}


## OPNsense API keys
variable "OPNSENSE_API_KEY" {
    type = string
}

variable "OPNSENSE_API_SECRET" {
    type = string
}

variable "OPNSENSE_ROUTER_IP" {
    type = string
}

### longhorn s3 backup creds and bucket

variable "LONGHORN_S3_BUCKET" {
    type = string
}

variable "LONGHORN_S3_KEY" {
    type = string
}

variable "LONGHORN_S3_KEY_ID" {
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

variable "DISCORD_STATUS_WEBHOOK" {
    type = string
}


# Jellyfin

variable "JELLYFIN_API_KEY" {
    type = string
}

## Secrets

resource "vault_kv_secret_v2" "cluster-settings" {
    mount    = vault_mount.kv.path
    name    = "cluster-settings"
    data_json = jsonencode({
        "domain_name" = var.DOMAIN_NAME
        "timezone" = var.TIMEZONE
        "ingress_ip" = var.INGRESS_IP
        "homeassistant_ip" = var.HOMEASSISTANT_IP
        "wg_easy_ip" = var.WG_EASY_IP
        "emqx_ip" = var.EMQX_IP
        "minecraft_ip" = var.MINECRAFT_IP
        "email_address" = var.EMAIL_ADDRESS
        "nfs_server_ip" = var.NFS_SERVER_IP
        "nfs_path" = var.NFS_PATH
        "omada_controller_ip" = var.OMADA_CONTROLLER_IP
    })
}

resource "vault_kv_secret_v2" "s3" {
    mount    = vault_mount.kv.path
    name    = "s3"
    data_json = jsonencode({
        "s3_endpoint" = var.S3_ENDPOINT
        "s3_endpoint_url" = "https://${var.S3_ENDPOINT}"
        "s3_region" = var.S3_REGION
    })
}


resource "vault_kv_secret_v2" "emqx" {
    mount    = vault_mount.kv.path
    name    = "emqx"
    data_json = jsonencode({
        "username" = var.EMQX_USERNAME
        "password" = var.EMQX_PASSWORD
    })
}

resource "vault_kv_secret_v2" "opnsense" {
    mount    = vault_mount.kv.path
    name    = "opnsense"
    data_json = jsonencode({
        "api_key" = var.OPNSENSE_API_KEY
        "api_secret" = var.OPNSENSE_API_SECRET
        "opnsense_router_ip" = var.OPNSENSE_ROUTER_IP
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

resource "vault_kv_secret_v2" "longhorn_s3" {
    mount    = vault_mount.kv.path
    name    = "longhorn_s3"
    data_json = jsonencode({
        "s3_bucket" = var.LONGHORN_S3_BUCKET
        "s3_key" = var.LONGHORN_S3_KEY
        "s3_key_id" = var.LONGHORN_S3_KEY_ID
    })
}

resource "vault_kv_secret_v2" "discord" {
    mount    = vault_mount.kv.path
    name    = "discord"
    data_json = jsonencode({
        "discord_media_webhook" = var.DISCORD_MEDIA_WEBHOOK
        "discord_notifications_webhook" = var.DISCORD_NOTIFICATIONS_WEBHOOK
        "discord_status_webhook" = var.DISCORD_STATUS_WEBHOOK
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

resource "random_password" "minio_oauth_client_id" {
    length = 32
    special = false
    numeric = false
    upper = false
}

resource "random_password" "minio_oauth_client_secret" {
    length = 32
    special = false
    numeric = false
    upper = false
}

resource "random_password" "minio_admin_password" {
    length = 32
    special = false
    numeric = false
    upper = false
}


resource "vault_kv_secret_v2" "minio_oauth" {
    mount    = vault_mount.kv.path
    name    = "minio_oauth"
    data_json = jsonencode({
        "client_id" = random_password.minio_oauth_client_id.result
        "client_secret" = random_password.minio_oauth_client_secret.result
        "admin_password" = random_password.minio_admin_password.result
    })
}

resource "random_password" "immich_db_password" {
  length = 32
  special = true
  numeric = true
  upper = true
}

resource "random_password" "immich_oauth_client_id" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "random_password" "immich_oauth_client_secret" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "vault_kv_secret_v2" "immich" {
    mount    = vault_mount.kv.path
    name    = "immich"
    data_json = jsonencode({
        "DB_PASSWORD" = random_password.immich_db_password.result
        "DB_USERNAME" = "immich"
    })
}

resource "vault_kv_secret_v2" "immich_oauth" {
    mount    = vault_mount.kv.path
    name    = "immich_oauth"
    data_json = jsonencode({
        "client_id" = random_password.immich_oauth_client_id.result
        "client_secret" = random_password.immich_oauth_client_secret.result
    })
}

resource "vault_kv_secret_v2" "frigate" {
    mount    = vault_mount.kv.path
    name    = "frigate"
    data_json = jsonencode({
        "camera_username" = var.FRIGATE_CAMERA_USERNAME
        "camera_password" = var.FRIGATE_CAMERA_PASSWORD
        "library_camera_ip" = var.FRIGATE_LIBRARY_CAMERA_IP
        "cat_room_camera_ip" = var.FRIGATE_CAT_ROOM_CAMERA_IP
        "library_camera_uid" = var.FRIGATE_LIBRARY_CAMERA_UID
        "cat_room_camera_uid" = var.FRIGATE_CAT_ROOM_CAMERA_UID
    })
}


resource "random_password" "donetick_db_password" {
  length  = 32
  special = false
}

resource "random_password" "donetick_jwt_secret" {
  length  = 32
  special = false
}

resource "vault_kv_secret_v2" "donetick" {
  mount               = vault_mount.kv.path
  name                = "donetick"
  data_json = jsonencode({
    db_host     = "donetick-rw.donetick.svc.cluster.local"
    db_port     = "5432"
    db_user     = "donetick"
    db_pass     = random_password.donetick_db_password.result
    db_name     = "donetick"
    jwt_secret  = random_password.donetick_jwt_secret.result
  })
}

resource "random_password" "n8n_encryption_key" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "vault_kv_secret_v2" "n8n" {
  mount    = vault_mount.kv.path
  name     = "n8n"
  data_json = jsonencode({
    "N8N_ENCRYPTION_KEY" = random_password.n8n_encryption_key.result
    })
}
resource "random_password" "donetick_oauth_client_id" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "random_password" "donetick_oauth_client_secret" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "vault_kv_secret_v2" "donetick_oauth" {
  mount               = vault_mount.kv.path
  name                = "donetick-oauth"
  data_json = jsonencode({
    client_id     = random_password.donetick_oauth_client_id.result
    client_secret = random_password.donetick_oauth_client_secret.result
  })
} 

resource "random_password" "open_webui_oauth_client_id" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "random_password" "open_webui_oauth_client_secret" {
  length = 32
  special = false
  numeric = false
  upper = false
}

resource "vault_kv_secret_v2" "open-webui-oauth" {
  mount               = vault_mount.kv.path
  name                = "open-webui-oauth"
  data_json = jsonencode({
    client_id     = random_password.open_webui_oauth_client_id.result
    client_secret = random_password.open_webui_oauth_client_secret.result
  })
}

resource "vault_kv_secret_v2" "jellyfin_arr" {
    mount    = vault_mount.kv.path
    name    = "jellyfin_arr"
    data_json = jsonencode({
        "api_key" = var.JELLYFIN_API_KEY
    })
}

resource "vault_kv_secret_v2" "irc" {
    mount    = vault_mount.kv.path
    name    = "irc"
    data_json = jsonencode({
      username = var.IRC_USERNAME
    })
}
resource "vault_kv_secret_v2" "vaultwarden" {
  mount    = vault_mount.kv.path
  name     = "vaultwarden"
  data_json = jsonencode({
    admin_token = random_password.vaultwarden_admin_token.result
  })
}

resource "random_password" "vaultwarden_admin_token" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
