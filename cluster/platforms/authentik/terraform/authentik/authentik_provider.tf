provider "authentik" {
  url   = "https://authentik.${var.domain_name}"
  token = var.AUTHENTIK_BOOTSTRAP_TOKEN
}
