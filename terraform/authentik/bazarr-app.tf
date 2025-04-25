module "bazarr" {
  source = "./modules/forward-auth-application"
  slug   = "bazarr"

  name   = "bazarr"
  domain_name = "bazarr.${var.domain_name}"
  group  = "media"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/health"
  meta_icon = "https://static.thenounproject.com/png/607762-200.png"
}

resource "authentik_group" "bazarr-users" {
  name = "bazarr-users"
}

resource "authentik_policy_binding" "bazarr-users-binding" {
  target = module.bazarr.application_id
  group = authentik_group.bazarr-users.id
  order = 0
}