resource "prowlarr_download_client_qbittorrent" "qbittorrent" {
  enable   = true
  priority = 2
  name     = "qbittorrent"
  host     = "qbittorrent.${var.cluster_media_domain}"
  url_base = "/"
  port     = var.ports["qbittorrent"]
  category = "prowlarr"
}


resource "prowlarr_application_sonarr" "sonarr" {
  name                  = "sonarr"
  sync_level            = "fullSync"
  base_url              = "http://sonarr.${var.cluster_media_domain}:${var.ports["sonarr"]}"
  prowlarr_url          = "http://prowlarr.${var.cluster_media_domain}:${var.ports["prowlarr"]}"
  api_key               = var.SONARR__AUTH__APIKEY
  sync_categories       = [5000, 5010, 5030]
  anime_sync_categories = [5070]
}

resource "prowlarr_application_radarr" "radarr" {
  name            = "radarr"
  sync_level      = "fullSync"
  base_url        = "http://radarr.${var.cluster_media_domain}:${var.ports["radarr"]}"
  prowlarr_url    = "http://prowlarr.${var.cluster_media_domain}:${var.ports["prowlarr"]}"
  api_key         = var.RADARR__AUTH__APIKEY
  sync_categories = [2000, 2010, 2030]
}
