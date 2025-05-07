module "alertmanager" {
  source = "./modules/forward-auth-application"
  slug   = "alertmanager"

  name   = "alertmanager"
  domain_name = "alertmanager.${var.domain_name}"
  group  = "monitoring"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  meta_icon = "https://s3.${var.domain_name}/media/alertmanager.png"
  skip_path_regex = "/-/healthy"
}

resource "authentik_group" "alertmanager-users" {
  name = "alertmanager-users"
}

resource "authentik_policy_binding" "alertmanager-users-binding" {
  target = module.alertmanager.application_id
  group = authentik_group.alertmanager-users.id
  order = 0
}