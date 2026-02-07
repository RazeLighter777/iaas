terraform {
  required_version = ">= 1.5.0"
  required_providers {
    opnsense = {
      source  = "browningluke/opnsense"
      version = "0.16.1"
    }
  }
}

provider "opnsense" {
  uri            = "https://${var.OPNSENSE_ROUTER_IP}"
  api_key        = var.OPNSENSE_API_KEY
  api_secret     = var.OPNSENSE_API_SECRET
  allow_insecure = true
}
