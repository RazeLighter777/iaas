module "longhorn" {
  source = "./modules/forward-auth-application"
  slug   = "longhorn"

  name   = "Longhorn"
  domain_name = "longhorn.${var.domain_name}"
  group  = "storage"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/v1/healthz"

  meta_icon = "https://s3.prizrak.me/longhorn.png"
}

resource "authentik_group" "longhorn-users" {
  name = "longhorn-users"
}

resource "authentik_policy_binding" "longhorn-users-binding" {
  target = module.longhorn.application_id
  group = authentik_group.longhorn-users.id
  order = 0
}
