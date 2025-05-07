module "gatus" {
  source = "./modules/forward-auth-application"
  slug   = "gatus"
  name   = "Gatus"
  domain_name = "status.${var.domain_name}"
  group  = "monitoring"
  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/health"
  meta_icon = "https://s3.${var.domain_name}/media/gatus.png"
}

resource "authentik_group" "gatus-users" {
  name = "gatus-users"
}

resource "authentik_policy_binding" "gatus-users-binding" {
  target = module.gatus.application_id
  group = authentik_group.gatus-users.id
  order = 0
}











