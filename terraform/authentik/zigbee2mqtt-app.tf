module "zigbee2mqtt" {
  source = "./modules/forward-auth-application"
  slug   = "zigbee2mqtt"
  name   = "Zigbee2MQTT"
  domain_name = "zigbee2mqtt.${var.domain_name}"
  group  = "networking"
  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  meta_icon = "https://s3.${var.domain_name}/media/zigbee2mqtt.png"
}

resource "authentik_group" "zigbee2mqtt-users" {
  name = "zigbee2mqtt-users"
}

resource "authentik_policy_binding" "zigbee2mqtt-users-binding" {
  target = module.zigbee2mqtt.application_id
  group = authentik_group.zigbee2mqtt-users.id
  order = 0
}