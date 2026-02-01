module "falco-ui" {
  source = "./modules/forward-auth-application"
  slug   = "falco-ui"

  name        = "Falco UI"
  domain_name = "falco-ui.${var.domain_name}"
  group       = "security"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id

  #meta_icon = "https://s3.${var.domain_name}/media/falco.png"
}

resource "authentik_group" "falco-ui-users" {
  name = "falco-ui-users"
}

resource "authentik_policy_binding" "falco-ui-users-binding" {
  target = module.falco-ui.application_id
  group  = authentik_group.falco-ui-users.id
  order  = 0
}
