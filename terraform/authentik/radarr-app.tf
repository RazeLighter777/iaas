module "radarr" {
  source = "./modules/forward-auth-application"
  slug   = "radarr"

  name   = "Radarr"
  domain_name = "radarr.${var.domain_name}"
  group  = "media"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id

  meta_icon = "https://git.zknt.org/mirror/Radarr/raw/commit/21ed073f294e8ab4d245f64dd6ae62f1c940b9f4/Logo/800.png"
}

resource "authentik_group" "radarr-users" {
  name = "radarr-users"
}

resource "authentik_policy_binding" "radarr-users-binding" {
  target = module.radarr.application_id
  group = authentik_group.radarr-users.id
  order = 0
}