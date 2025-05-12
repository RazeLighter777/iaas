variable "donetick_client_id" {
  description = "The client ID for the Donetick OAuth2 provider"
}

variable "donetick_client_secret" {
  description = "The client secret for the Donetick OAuth2 provider"
}

resource "authentik_provider_oauth2" "donetick" {
  name          = "Donetick"
  client_id     = var.donetick_client_id
  client_secret = var.donetick_client_secret

  authorization_flow  = data.authentik_flow.default-authorization-flow.id
  invalidation_flow   = data.authentik_flow.default-provider-invalidation-flow.id
  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "https://donetick.${var.domain_name}/auth/oauth2"
    }
  ]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
  ]
}

resource "authentik_application" "donetick" {
  name              = "Donetick"
  slug              = "donetick"
  protocol_provider = authentik_provider_oauth2.donetick.id
  group             = "productivity"
  meta_icon         = "https://s3.${var.domain_name}/media/donetick.svg"

}

resource "authentik_group" "donetick_users" {
  name    = "Donetick Users"
}
