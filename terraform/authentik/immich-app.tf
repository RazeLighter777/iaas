variable "immich_client_id" {
  description = "The client ID for the Immich OAuth2 provider"
}

variable "immich_client_secret" {
  description = "The client secret for the Immich OAuth2 provider"
}

resource "authentik_provider_oauth2" "immich" {
  name          = "Immich"
  client_id     = var.immich_client_id
  client_secret = var.immich_client_secret

  authorization_flow  = data.authentik_flow.default-authorization-flow.id
  invalidation_flow   = data.authentik_flow.default-provider-invalidation-flow.id
  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "app.immich:///oauth-callback"
    },
    {
      matching_mode = "strict"
      url           = "https://immich.${var.domain_name}/auth/login"
    },
    {
      matching_mode = "strict"
      url           = "https://immich.${var.domain_name}/user-settings"
    }
  ]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
  ]
}

resource "authentik_application" "immich" {
  name              = "Immich"
  slug              = "immich"
  protocol_provider = authentik_provider_oauth2.immich.id
  group             = "media"
  meta_icon         = "https://s3.prizrak.me/media/immich.png"
  meta_launch_url   = "https://immich.${var.domain_name}"
}

resource "authentik_group" "immich_users" {
  name = "immich-users"
}

resource "authentik_policy_binding" "immich_users_binding" {
  target = authentik_application.immich.uuid
  group = authentik_group.immich_users.id
  order = 0
}
