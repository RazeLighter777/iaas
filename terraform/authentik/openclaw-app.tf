module "openclaw" {
  source = "./modules/forward-auth-application"
  slug   = "openclaw"
  name   = "OpenClaw"
  domain_name = "clawdbot.${var.domain_name}"
  group  = "AI Slop"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/health"

  meta_icon = "https://s3.${var.domain_name}/media/openclaw.png"
}

resource "authentik_group" "openclaw-users" {
  name = "openclaw-users"
}

resource "authentik_policy_binding" "openclaw-users-binding" {
  target = module.openclaw.application_id
  group = authentik_group.openclaw-users.id
  order = 0
}
