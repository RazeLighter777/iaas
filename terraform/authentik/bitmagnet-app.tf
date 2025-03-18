module "bitmagnet" {
  source = "./modules/forward-auth-application"
  slug   = "bitmagnet"

  name   = "Bitmagnet"
  domain_name = "bitmagnet.${var.domain_name}"
  group  = "trackers"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  meta_icon = "https://static.thenounproject.com/png/607762-200.png"
}

resource "authentik_group" "bitmagnet-users" {
  name = "alertmanager-users"
}

resource "authentik_policy_binding" "bitmagnet-users-binding" {
  target = module.bitmagnet.application_id
  group = authentik_group.bitmagnet-users.id
  order = 0
}