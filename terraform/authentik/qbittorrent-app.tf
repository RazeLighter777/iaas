module "qbittorrent" {
  source = "./modules/forward-auth-application"
  slug   = "qbittorrent"

  name   = "qBittorrent"
  domain_name = "qbittorrent.${var.domain_name}"
  group  = "media"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/api/v2/app/version"

  meta_icon = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/New_qBittorrent_Logo.svg/800px-New_qBittorrent_Logo.svg.png"
}

resource "authentik_group" "qbittorrent-users" {
  name = "qbittorrent-users"
}

resource "authentik_policy_binding" "qbittorrent-users-binding" {
  target = module.qbittorrent.application_id
  group = authentik_group.qbittorrent-users.id
  order = 0
}