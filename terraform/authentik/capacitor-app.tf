module "capacitor" {
  source = "./modules/forward-auth-application"
  slug   = "capacitor"

  name   = "Capacitor"
  domain_name = "capacitor.${var.domain_name}"
  group  = "monitoring"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id

  meta_icon = "https://fluxcd.io/img/logos/flux-stacked-color.png"
}

resource "authentik_group" "capacitor-users" {
  name = "capacitor-users"
}

resource "authentik_policy_binding" "capacitor-users-binding" {
  target = module.capacitor.application_id
  group = authentik_group.capacitor-users.id
  order = 0
}