variable "open_webui_client_id" {
  description = "The client ID for the Open WebUI OAuth2 provider"
}

variable "open_webui_client_secret" {
  description = "The client secret for the Open WebUI OAuth2 provider"
}

resource "authentik_provider_oauth2" "open_webui" {
  name          = "Open WebUI"
  client_id     = var.open_webui_client_id
  client_secret = var.open_webui_client_secret

  authorization_flow  = data.authentik_flow.default-authorization-flow.id
  invalidation_flow   = data.authentik_flow.default-provider-invalidation-flow.id
  signing_key    = data.authentik_certificate_key_pair.default.id

  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "https://openwebui.${var.domain_name}/oauth/oidc/callback"
    }
  ]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
  ]
}

resource "authentik_application" "open_webui" {
  name              = "Open WebUI"
  slug              = "open-webui"
  protocol_provider = authentik_provider_oauth2.open_webui.id
  group             = "AI Slop"
  meta_icon         = "https://s3.${var.domain_name}/media/open-webui.svg"
}

resource "authentik_group" "open_webui_users" {
  name    = "Open WebUI Users"
}
