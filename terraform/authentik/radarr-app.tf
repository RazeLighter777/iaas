module "radarr" {
  source = "./modules/forward-auth-application"
  slug   = "radarr"

  name   = "Radarr"
  domain_name = "radarr.${var.domain_name}"
  group  = "media"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/ping"

  meta_icon = "https://s3.${var.domain_name}/media/radarr.png"
}

resource "authentik_group" "radarr-users" {
  name = "radarr-users"
}

resource "authentik_policy_binding" "radarr-users-binding" {
  target = module.radarr.application_id
  group = authentik_group.radarr-users.id
  order = 0
}