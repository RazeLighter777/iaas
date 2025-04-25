module "prowlarr" {
  source = "./modules/forward-auth-application"
  slug   = "prowlarr"

  name   = "Prowlarr"
  domain_name = "prowlarr.${var.domain_name}"
  group  = "media"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/ping"

  meta_icon = "https://prowlarr.com/logo/128.png"
}

resource "authentik_group" "prowlarr-users" {
  name = "prowlarr-users"
}

resource "authentik_policy_binding" "prowlarr-users-binding" {
  target = module.prowlarr.application_id
  group = authentik_group.prowlarr-users.id
  order = 0
}

