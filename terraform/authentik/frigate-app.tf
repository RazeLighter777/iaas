module "frigate" {
  source = "./modules/forward-auth-application"
  slug   = "frigate"

  name   = "Frigate"
  domain_name = "frigate.${var.domain_name}"
  group  = "media"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/api/version"

  meta_icon = "https://s3.${var.domain_name}/media/frigate.svg"

}

resource "authentik_group" "frigate-users" {
  name = "frigate-users"
}

resource "authentik_policy_binding" "frigate-users-binding" {
  target = module.frigate.application_id
  group = authentik_group.frigate-users.id
  order = 0
}
