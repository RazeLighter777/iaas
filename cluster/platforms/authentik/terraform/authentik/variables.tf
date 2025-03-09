variable "AUTHENTIK_BOOTSTRAP_TOKEN" {
  type = string
  description = "Bootstrap token for authentik"
}

variable "service_url" {
  type = string
  description = "API URL for authentik"
}

variable "domain_name" {
  type = string
  description = "Domain name for authentik"
}