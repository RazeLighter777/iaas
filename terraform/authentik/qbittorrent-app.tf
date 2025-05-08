module "qbittorrent" {
  source = "./modules/forward-auth-application"
  slug   = "qbittorrent"

  name   = "qBittorrent"
  domain_name = "qbittorrent.${var.domain_name}"
  group  = "media"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/api/v2/app/version"

  meta_icon = "https://s3.${var.domain_name}/media/qbittorrent.png"
}

resource "authentik_group" "qbittorrent-users" {
  name = "qbittorrent-users"
}

resource "authentik_policy_binding" "qbittorrent-users-binding" {
  target = module.qbittorrent.application_id
  group = authentik_group.qbittorrent-users.id
  order = 0
}