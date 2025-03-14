variable "domain_name" {
  type        = string
  description = "public domain name"
}

variable "cluster_media_domain" {
  type        = string
  default     = "media.svc.cluster.local"
  description = "Cluster Media Namespace Domain"
}

variable "ports" {
  type = map(string)
  default = {
    "sonarr"      = "8989"
    "prowlarr"    = "8989"
    "radarr"      = "8989"
    "qbittorrent" = "8080"
  }
  description = "Mapping of services to their respective ports"
}

variable "SONARR__AUTH__APIKEY" {
  type        = string
  description = "Sonarr API Key"
}

variable "RADARR__AUTH__APIKEY" {
  type        = string
  description = "Radarr API Key"
}

variable "PROWLARR__AUTH__APIKEY" {
  type        = string
  description = "Prowlarr API Key"
}