provider "authentik" {
  url   = var.service_url
  insecure = true
  token = var.AUTHENTIK_BOOTSTRAP_TOKEN
}
