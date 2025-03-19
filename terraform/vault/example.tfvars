CLUSTER_NAME = "your-cluster-name"

# Globals
DOMAIN_NAME = "example.com"
TIMEZONE = "America/New_York"
INGRESS_IP = "192.168.1.x"
TRUENAS_IP = "192.168.1.x"

# TrueNAS
TRUENAS_MEDIA_SHARE_PATH = "/mnt/path/to/media"
TRUENAS_ISCSI_SHARE_PATH = "path/to/iscsi"
TRUENAS_API_KEY = "your-truenas-api-key"

# S3 backups
S3_ENDPOINT = "https://s3.example.com"
S3_REGION = "us-east-1"

# Cloudnative PG
CLOUDNATIVE_S3_BUCKET = "your-bucket-name"
CLOUDNATIVE_S3_KEY = "your-s3-key"
CLOUDNATIVE_S3_KEY_ID = "your-s3-key-id"

# Authentik
AUTHENTIK_BOOTSTRAP_PASSWORD = "your-secure-password"
AUTHENTIK_BOOTSTRAP_EMAIL = "admin@example.com"

# Cloudflare
CLOUDFLARE_API_TOKEN = "your-cloudflare-api-token"

# Private internet access
PRIVATE_INTERNET_ACCESS_USERNAME = "your-username"
PRIVATE_INTERNET_ACCESS_PASSWORD = "your-password"

# Discord webhooks
DISCORD_NOTIFICATIONS_WEBHOOK = "https://discordapp.com/api/webhooks/your-webhook-id/your-webhook-token"
DISCORD_MEDIA_WEBHOOK = "https://discordapp.com/api/webhooks/your-webhook-id/your-webhook-token"
````

I've replaced all sensitive information with generic placeholders while maintaining the structure of the original file. This makes it safe to commit to version control as an example template.
