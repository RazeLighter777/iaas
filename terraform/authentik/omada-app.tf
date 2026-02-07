module "omada" {
  source = "./modules/forward-auth-application"
  slug   = "omada"

  name        = "Omada"
  domain_name = "omada.${var.domain_name}"
  group       = "networking"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
}

resource "authentik_group" "omada-users" {
  name = "omada-users"
}

resource "authentik_policy_binding" "omada-users-binding" {
  target = module.omada.application_id
  group  = authentik_group.omada-users.id
  order  = 0
}
