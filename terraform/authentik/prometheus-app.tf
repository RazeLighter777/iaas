module "prometheus" {
  source = "./modules/forward-auth-application"
  slug   = "prometheus"

  name   = "Prometheus"
  domain_name = "prometheus.${var.domain_name}"
  group  = "monitoring"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/-/healthy"

  meta_icon = "https://s3.${var.domain_name}/media/prometheus.png"
}

resource "authentik_group" "prometheus-users" {
  name = "prometheus-users"
}

resource "authentik_policy_binding" "prometheus-users-binding" {
  target = module.prometheus.application_id
  group = authentik_group.prometheus-users.id
  order = 0
}