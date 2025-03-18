module "prowlarr" {
  source = "./modules/forward-auth-application"
  slug   = "prowlarr"

  name   = "Prowlarr"
  domain_name = "prowlarr.${var.domain_name}"
  group  = "media"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id

  meta_icon = "https://prowlarr.com/logo/128.png"
}

resource "authentik_group" "prowlarr-users" {
  name = "prowlarr-users"
}

resource "authentik_policy_binding" "prowlarr-users-binding" {
  target = module.prowlarr.application_id
  group = authentik_group.prowlarr-users.id
  order = 0
}

resource "prowlarr_notification_discord" "media_discord" {
  on_health_issue       = true
  on_application_update = false

  include_health_warnings = false
  name                    = "Media Discord"

  web_hook_url  = var.discord_media_webhook
  username      = "Prowlarr"
  avatar        = "https://static-00.iconduck.com/assets.00/prowlarr-icon-1024x1024-vyf0hy1t.png"
  grab_fields   = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  import_fields = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
}
