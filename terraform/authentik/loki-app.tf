module "loki" {
  source = "./modules/forward-auth-application"
  slug   = "loki"

  name   = "Loki"
  domain_name = "loki.${var.domain_name}"
  group  = "monitoring"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/ready"

  meta_icon = "https://s3.${var.domain_name}/media/loki.svg"
}

resource "authentik_group" "loki-users" {
  name = "loki-users"
}

resource "authentik_policy_binding" "loki-users-binding" {
  target = module.loki.application_id
  group = authentik_group.loki-users.id
  order = 0
} 