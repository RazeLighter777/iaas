terraform {
  required_version = "1.11.2"
  required_providers {
    sonarr = {
      source  = "devopsarr/sonarr"
      version = "3.4.0"
    }
    prowlarr = {
      source  = "devopsarr/prowlarr"
      version = "3.0.2"
    }
    radarr = {
      source  = "devopsarr/radarr"
      version = "2.3.2"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2"
    }
  }
}



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