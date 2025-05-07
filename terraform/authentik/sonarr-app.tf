module "sonarr" {
  source = "./modules/forward-auth-application"
  slug   = "sonarr"

  name   = "Sonarr"
  domain_name = "sonarr.${var.domain_name}"
  group  = "media"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/ping"

  meta_icon = "https://s3.prizrak.me/sonarr.png"
}

resource "authentik_group" "sonarr-users" {
  name = "sonarr-users"
}

resource "authentik_policy_binding" "sonarr-users-binding" {
  target = module.sonarr.application_id
  group = authentik_group.sonarr-users.id
  order = 0
}