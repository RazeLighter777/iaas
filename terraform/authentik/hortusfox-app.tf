module "hortusfox" {
  source      = "./modules/forward-auth-application"
  slug        = "hortusfox"
  name        = "HortusFox"
  domain_name = "plants.${var.domain_name}"
  group       = "productivity"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
}

resource "authentik_group" "hortusfox-users" {
  name = "hortusfox-users"
}

resource "authentik_policy_binding" "hortusfox-users-binding" {
  target = module.hortusfox.application_id
  group  = authentik_group.hortusfox-users.id
  order  = 0
}
