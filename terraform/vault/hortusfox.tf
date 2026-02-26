### HortusFox

resource "random_password" "hortusfox_db_password" {
  length  = 32
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "hortusfox_admin_password" {
  length  = 32
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "hortusfox_mysql_root_password" {
  length  = 32
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "hortusfox_mysql_xtrabackup_password" {
  length  = 32
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "hortusfox_mysql_monitor_password" {
  length  = 32
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "hortusfox_mysql_clustercheck_password" {
  length  = 32
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "hortusfox_mysql_proxyadmin_password" {
  length  = 32
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "hortusfox_mysql_operator_password" {
  length  = 32
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "hortusfox_mysql_replication_password" {
  length  = 32
  special = false
  numeric = true
  upper   = true
}

resource "random_password" "hortusfox_mysql_heartbeat_password" {
  length  = 32
  special = false
  numeric = true
  upper   = true
}

resource "vault_kv_secret_v2" "hortusfox" {
  mount     = vault_mount.kv.path
  name      = "hortusfox"
  data_json = jsonencode({
    db_password                 = random_password.hortusfox_db_password.result
    admin_email                 = var.HORTUSFOX_ADMIN_EMAIL
    admin_password              = random_password.hortusfox_admin_password.result
    mysql_root_password         = random_password.hortusfox_mysql_root_password.result
    mysql_xtrabackup_password   = random_password.hortusfox_mysql_xtrabackup_password.result
    mysql_monitor_password      = random_password.hortusfox_mysql_monitor_password.result
    mysql_clustercheck_password = random_password.hortusfox_mysql_clustercheck_password.result
    mysql_proxyadmin_password   = random_password.hortusfox_mysql_proxyadmin_password.result
    mysql_operator_password     = random_password.hortusfox_mysql_operator_password.result
    mysql_replication_password  = random_password.hortusfox_mysql_replication_password.result
    mysql_heartbeat_password    = random_password.hortusfox_mysql_heartbeat_password.result
  })
}
