module "bitmagnet" {
  source = "./modules/forward-auth-application"
  slug   = "bitmagnet"

  name   = "Bitmagnet"
  domain_name = "bitmagnet.${var.domain_name}"
  group  = "networking"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/status"
  meta_icon = "https://s3.${var.domain_name}/media/bitmagnet.png"
}

resource "authentik_group" "bitmagnet-users" {
  name = "bitmagnet-users"
}

resource "authentik_policy_binding" "bitmagnet-users-binding" {
  target = module.bitmagnet.application_id
  group = authentik_group.bitmagnet-users.id
  order = 0
}