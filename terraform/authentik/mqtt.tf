module "mqtt" {
  source = "./modules/forward-auth-application"
  slug   = "mqtt"

  name   = "Mqtt"
  domain_name = "mqtt.${var.domain_name}"
  group  = "networking"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/ping"

  meta_icon = null
}

resource "authentik_group" "mqtt-users" {
  name = "mqtt-users"
}

resource "authentik_policy_binding" "mqtt-users-binding" {
  target = module.mqtt.application_id
  group = authentik_group.mqtt-users.id
  order = 0
}