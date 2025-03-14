provider "sonarr" {
  url     = "https://sonarr.${var.local_domain}"
  api_key = var.SONARR__AUTH__APIKEY
}

provider "radarr" {
  url     = "https://radarr.${var.local_domain}"
  api_key = var.RADARR__AUTH__APIKEY
}

provider "prowlarr" {
  url     = "https://prowlarr.${var.local_domain}"
  api_key = var.PROWLARR__AUTH__APIKEY
}