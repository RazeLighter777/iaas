### Harbor

resource "random_password" "harbor_admin_password" {
  length  = 32
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "harbor_db_password" {
  length  = 32
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "harbor_oauth_client_id" {
  length  = 32
  special = false
  numeric = false
  upper   = false
}

resource "random_password" "harbor_oauth_client_secret" {
  length  = 32
  special = false
  numeric = false
  upper   = false
}

resource "vault_kv_secret_v2" "harbor" {
  mount     = vault_mount.kv.path
  name      = "harbor"
  data_json = jsonencode({
    admin_username = "admin"
    admin_password = random_password.harbor_admin_password.result
    db_password    = random_password.harbor_db_password.result
  })
}

resource "vault_kv_secret_v2" "harbor_oauth" {
  mount     = vault_mount.kv.path
  name      = "harbor_oauth"
  data_json = jsonencode({
    client_id     = random_password.harbor_oauth_client_id.result
    client_secret = random_password.harbor_oauth_client_secret.result
  })
}
