module "zwavejsui" {
  source = "./modules/forward-auth-application"
  slug   = "zwavejsui"
  name   = "Z-Wave JS UI"
  domain_name = "zwavejsui.${var.domain_name}"
  group  = "networking"
  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  meta_icon = "https://s3.${var.domain_name}/media/zwavejsui.png"
}

resource "authentik_group" "zwavejsui-users" {
  name = "zwavejsui-users"
}

resource "authentik_policy_binding" "zwavejsui-users-binding" {
  target = module.zwavejsui.application_id
  group = authentik_group.zwavejsui-users.id
  order = 0
}