module "booktok" {
  source = "./modules/forward-auth-application"
  slug   = "booktok"

  name   = "Booktok"
  domain_name = "booktok.${var.domain_name}"
  group  = "media"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/cwa-check-monitoring"

  meta_icon = "https://pbs.twimg.com/media/GJNyxbkbMAAcnYl.png"
}

resource "authentik_group" "booktok-users" {
  name = "booktok-users"
}

resource "authentik_policy_binding" "booktok-users-binding" {
  target = module.booktok.application_id
  group = authentik_group.booktok-users.id
  order = 0
}