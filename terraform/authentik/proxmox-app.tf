variable "proxmox_client_id" {
  description = "The client ID for the proxmox OAuth2 provider"
}

variable "proxmox_client_secret" {
  description = "The client secret for the proxmox OAuth2 provider"
}

resource "authentik_provider_oauth2" "proxmox" {
  name          = "proxmox"
  client_id     = var.proxmox_client_id
  client_secret = var.proxmox_client_secret

  authorization_flow  = data.authentik_flow.default-authorization-flow.id
  invalidation_flow   = data.authentik_flow.default-provider-invalidation-flow.id
  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "https://proxmox.${var.domain_name}"
    }
  ]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
  ]
}

resource "authentik_application" "proxmox" {
  name              = "Proxmox"
  slug              = "proxmox"
  protocol_provider = authentik_provider_oauth2.proxmox.id
  group             = "cloud"
  meta_icon         = "https://avatars.githubusercontent.com/u/2678585?s=280&v=4"

}

resource "authentik_group" "proxmox_admins" {
  name    = "Proxmox Admins"
}

resource "authentik_group" "proxmox_tenants" {
  name    = "Proxmox Tenants"
}