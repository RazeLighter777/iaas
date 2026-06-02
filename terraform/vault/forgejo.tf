### Forgejo

resource "random_password" "forgejo_db_password" {
  length  = 32
  special = true
  numeric = true
  upper   = true
}

resource "random_password" "forgejo_admin_password" {
  length  = 32
  special = true
  numeric = true
  upper   = true
}

resource "random_password" "forgejo_oidc_client_id" {
  length  = 40
  special = false
  numeric = false
  upper   = false
}

resource "random_password" "forgejo_oidc_client_secret" {
  length  = 60
  special = false
  numeric = false
  upper   = false
}

resource "random_password" "forgejo_secret_key" {
  length  = 64
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "forgejo_internal_token" {
  length  = 105
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "forgejo_jwt_secret" {
  length  = 43
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "forgejo_lfs_jwt_secret" {
  length  = 43
  special = false
  numeric = true
  upper   = true
}

resource "random_uuid" "forgejo_runner_uuid" {}

variable "FORGEJO_RUNNER_TOKEN" {
  type        = string
  description = "Registration token issued by Forgejo (Site Admin -> Actions -> Runners -> Create new Runner)."
  sensitive   = true
}

resource "vault_kv_secret_v2" "forgejo" {
  mount = vault_mount.kv.path
  name  = "forgejo"
  data_json = jsonencode({
    db_password        = random_password.forgejo_db_password.result
    admin_password     = random_password.forgejo_admin_password.result
    oidc_client_id     = random_password.forgejo_oidc_client_id.result
    oidc_client_secret = random_password.forgejo_oidc_client_secret.result
    secret_key         = random_password.forgejo_secret_key.result
    internal_token     = random_password.forgejo_internal_token.result
    jwt_secret         = random_password.forgejo_jwt_secret.result
    lfs_jwt_secret     = random_password.forgejo_lfs_jwt_secret.result
    runner_uuid        = random_uuid.forgejo_runner_uuid.result
    runner_token       = var.FORGEJO_RUNNER_TOKEN
  })
}
