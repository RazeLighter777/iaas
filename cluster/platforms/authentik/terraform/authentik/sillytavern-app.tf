module "sillytavern" {
  source = "./modules/forward-auth-application"
  slug   = "sillytavern"
  name   = "Sillytavern"
  domain_name = "radarr.${var.domain_name}"
  group  = "AI Slop"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id

  meta_icon = "https://upload.wikimedia.org/wikipedia/commons/6/6b/SillyTavern_logo_%28dark_background%29.png"
}

resource "authentik_group" "sillytavern-users" {
  name = "radarr-users"
}

resource "authentik_policy_binding" "sillytavern-users-binding" {
  target = module.sillytavern.application_id
  group = authentik_group.sillytavern-users.id
  order = 0
}