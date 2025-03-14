provider "sonarr" {
  url     = "http://sonarr.${var.cluster_media_domain}:${var.ports["sonarr"]}"
  api_key = var.SONARR__AUTH__APIKEY
}

provider "radarr" {
  url     = "http://radarr.${var.cluster_media_domain}:${var.ports["radarr"]}"
  api_key = var.RADARR__AUTH__APIKEY
}

provider "prowlarr" {
  url     = "http://prowlarr.${var.cluster_media_domain}:${var.ports["prowlarr"]}"
  api_key = var.PROWLARR__AUTH__APIKEY
}