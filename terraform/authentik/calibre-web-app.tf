module "cwa" {
  source = "./modules/forward-auth-application"
  slug   = "cwa"

  name   = "Calibre Web Automated"
  domain_name = "calibre-web.${var.domain_name}"
  group  = "media"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id

  meta_icon = "https://fluxcd.io/img/logos/flux-stacked-color.png"
}

resource "authentik_group" "cwa-users" {
  name = "calibre-web-users"
}

resource "authentik_policy_binding" "cwa-users-binding" {
  target = module.cwa.application_id
  group = authentik_group.cwa-users.id
  order = 0
}