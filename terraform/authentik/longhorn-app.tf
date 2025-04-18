module "longhorn" {
  source = "./modules/forward-auth-application"
  slug   = "longhorn"

  name   = "Longhorn"
  domain_name = "longhorn.${var.domain_name}"
  group  = "storage"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id

  meta_icon = "https://landscape.cncf.io/logos/acd3d31cbdf0aa2ef2d695fa4a3571e6d232a96214ec33fe0b2022b9719c244c.svg"
}

resource "authentik_group" "longhorn-users" {
  name = "longhorn-users"
}

resource "authentik_policy_binding" "longhorn-users-binding" {
  target = module.longhorn.application_id
  group = authentik_group.longhorn-users.id
  order = 0
}
