### FreshRSS

resource "random_password" "freshrss_db_password" {
  length  = 32
  special = true
  numeric = true
  upper   = true
}

resource "random_password" "freshrss_oidc_client_id" {
  length  = 32
  special = false
  numeric = false
  upper   = false
}

resource "random_password" "freshrss_oidc_client_secret" {
  length  = 32
  special = false
  numeric = false
  upper   = false
}

resource "random_password" "freshrss_oidc_client_crypto_key" {
  length  = 32
  special = false
  numeric = false
  upper   = false
}

resource "vault_kv_secret_v2" "freshrss" {
  mount     = vault_mount.kv.path
  name      = "freshrss"
  data_json = jsonencode({
    db_password              = random_password.freshrss_db_password.result
    oidc_client_id           = random_password.freshrss_oidc_client_id.result
    oidc_client_secret       = random_password.freshrss_oidc_client_secret.result
    oidc_client_crypto_key   = random_password.freshrss_oidc_client_crypto_key.result
  })
}
