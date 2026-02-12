CLUSTER_NAME = "your-cluster-name"

# Vault

VAULT_ADDR = "vault.example.com"
VAULT_TOKEN = "your-vault-token"

# Globals

DOMAIN_NAME = "example.com"
TIMEZONE = "America/New_York"
INGRESS_IP = "192.168.1.x"
HOMEASSISTANT_IP = "192.168.1.x"
WG_EASY_IP = "192.168.1.x"
EMQX_IP = "192.168.1.x"
MINECRAFT_IP = "192.168.1.x"
EMAIL_ADDRESS = "your-email@example.com"


# S3 backups

S3_ENDPOINT = "https://s3.example.com"
S3_REGION = "us-east-1"

# Emqx
EMQX_USERNAME = "admin"
EMQX_PASSWORD = "password"


# Cameras

FRIGATE_CAMERA_USERNAME = "admin"
FRIGATE_CAMERA_PASSWORD = "password"
FRIGATE_LIBRARY_CAMERA_IP = "192.168.1.x"
FRIGATE_CAT_ROOM_CAMERA_IP = "192.168.1.x"
FRIGATE_LIBRARY_CAMERA_UID = "ABCDEF0123456789"
FRIGATE_CAT_ROOM_CAMERA_UID = "BCDEF0123456789A"

# Cloudnative PG

CLOUDNATIVE_S3_BUCKET = "your-bucket-name"
CLOUDNATIVE_S3_KEY = "your-s3-key"
CLOUDNATIVE_S3_KEY_ID = "your-s3-key-id"

# Mikrotik
MIKROTIK_BASEURL = "https://mikrotik.example.com"
MIKROTIK_USERNAME = "your-mikrotik-username"
MIKROTIK_PASSWORD = "your-mikrotik-password"

# Longhorn S3 backup

LONGHORN_S3_BUCKET = "your-longhorn-bucket-name"
LONGHORN_S3_KEY = "your-longhorn-s3-key"
LONGHORN_S3_KEY_ID = "your-longhorn-s3-key-id"

# Authentik

AUTHENTIK_BOOTSTRAP_PASSWORD = "your-secure-password"
AUTHENTIK_BOOTSTRAP_EMAIL = "admin@example.com"

# Cloudflare

CLOUDFLARE_API_TOKEN = "your-cloudflare-api-token"
CLOUDFLARE_ARGO_TUNNEL_CREDS = "your-cloudflare-tunnel-credentials"
CLOUDFLARE_ARGO_TUNNEL_ID = "your-cloudflare-tunnel-id"

# Private internet access

PRIVATE_INTERNET_ACCESS_USERNAME = "your-username"
PRIVATE_INTERNET_ACCESS_PASSWORD = "your-password"

# Discord webhooks

DISCORD_NOTIFICATIONS_WEBHOOK = "https://discordapp.com/api/webhooks/your-webhook-id/your-webhook-token"
DISCORD_MEDIA_WEBHOOK = "https://discordapp.com/api/webhooks/your-webhook-id/your-webhook-token"

# NFS mount

NFS_SERVER_IP = "192.168.1.x"
NFS_PATH = "/mnt/mainpool"

# Jellyfin

JELLYFIN_API_KEY = "your-jellyfin-api-key"

# Nix build service

NIX_BUILDER_AUTHORIZED_KEYS = <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBUILDERPUBKEYEXAMPLE nix-build
EOF

NIX_SSH_HOST_RSA_KEY = <<EOF
-----BEGIN RSA PRIVATE KEY-----
REPLACE_WITH_SSH_HOST_RSA_PRIVATE_KEY
-----END RSA PRIVATE KEY-----
EOF

NIX_SSH_HOST_ED25519_KEY = <<EOF
-----BEGIN OPENSSH PRIVATE KEY-----
REPLACE_WITH_SSH_HOST_ED25519_PRIVATE_KEY
-----END OPENSSH PRIVATE KEY-----
EOF

NIX_CACHE_PRIVATE_KEY = <<EOF
your-cache-name:REPLACE_WITH_NIX_CACHE_PRIVATE_KEY
EOF

NIX_CACHE_PUBLIC_KEY = "your-cache-name:REPLACE_WITH_NIX_CACHE_PUBLIC_KEY"

NIX_CACHE_LB_IP = "192.168.1.1"

NIX_CACHE_S3_BUCKET = "your-nix-cache-bucket"
NIX_CACHE_S3_ENDPOINT = "s3.example.com"
NIX_CACHE_S3_REGION = "us-east-1"
NIX_CACHE_S3_SCHEME = "https"
NIX_CACHE_S3_ACCESS_KEY_ID = "your-nix-cache-s3-access-key-id"
NIX_CACHE_S3_SECRET_ACCESS_KEY = "your-nix-cache-s3-secret-access-key"

# Graphite exporter IP
GRAPHITE_EXPORTER_IP=192.168.1.x