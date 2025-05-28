module "openbooks" {
  source = "./modules/forward-auth-application"
  slug   = "openbooks"

  name   = "OpenBooks"
  domain_name = "openbooks.${var.domain_name}"
  group  = "media"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/cwa-check-monitoring"

  meta_icon = "https://s3.${var.domain_name}/media/openbooks.svg"
}

resource "authentik_group" "openbooks-users" {
  name = "openbooks-users"
}

resource "authentik_policy_binding" "openbooks-users-binding" {
  target = module.openbooks.application_id
  group = authentik_group.openbooks-users.id
  order = 0
}
