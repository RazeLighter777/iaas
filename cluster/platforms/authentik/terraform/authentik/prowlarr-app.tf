module "prowlarr" {
  source = "./modules/forward-auth-application"
  slug   = "prowlarr"

  name   = "Prowlarr"
  domain_name = "prowlarr.${var.domain_name}"
  group  = "media"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id

  meta_icon = "https://user-images.githubusercontent.com/31781818/33885790-bc32aec0-df1a-11e7-83df-3bf737de68c5.png"
}

resource "authentik_group" "prowlarr-users" {
  name = "prowlarr-users"
}

resource "authentik_policy_binding" "prowlarr-users-binding" {
  target = module.prowlarr.application_id
  group = authentik_group.prowlarr-users.id
  order = 0
}