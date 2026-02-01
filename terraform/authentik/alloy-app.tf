module "alloy" {
  source = "./modules/forward-auth-application"
  slug   = "alloy"

  name        = "Alloy"
  domain_name = "alloy.${var.domain_name}"
  group       = "monitoring"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/ready"

  #meta_icon = "https://s3.${var.domain_name}/media/alloy.png"
}

resource "authentik_group" "alloy-users" {
  name = "alloy-users"
}

resource "authentik_policy_binding" "alloy-users-binding" {
  target = module.alloy.application_id
  group  = authentik_group.alloy-users.id
  order  = 0
}
