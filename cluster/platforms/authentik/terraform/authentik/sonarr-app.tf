module "sonarr" {
  source = "./modules/forward-auth-application"
  slug   = "sonarr"

  name   = "Sonarr"
  domain_name = "sonarr.${var.domain_name}"
  group  = "media"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id

  meta_icon = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/web-check.png"
}

resource "authentik_group" "sonarr_users" {
  name = "sonarr-users"
}

resource "authentik_policy_binding" "sonarr-users-binding" {
  target = module.sonarr.application.id
  policy = authentik_policy_group.sonarr-users.id
}