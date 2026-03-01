variable "harbor_client_id" {
  description = "The client ID for the Harbor OAuth2 provider"
}

variable "harbor_client_secret" {
  description = "The client secret for the Harbor OAuth2 provider"
}

resource "authentik_provider_oauth2" "harbor" {
  name          = "Harbor"
  client_id     = var.harbor_client_id
  client_secret = var.harbor_client_secret

  authorization_flow  = data.authentik_flow.default-authorization-flow.id
  invalidation_flow   = data.authentik_flow.default-provider-invalidation-flow.id
  signing_key         = data.authentik_certificate_key_pair.default.id

  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "https://harbor.${var.domain_name}/c/oidc/callback"
    }
  ]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    data.authentik_property_mapping_provider_scope.scope-offline-access.id,
  ]
}

resource "authentik_application" "harbor" {
  name              = "Harbor"
  slug              = "harbor"
  protocol_provider = authentik_provider_oauth2.harbor.id
  group             = "infrastructure"
  meta_icon         = "https://s3.${var.domain_name}/media/harbor.png"
  meta_launch_url   = "https://harbor.${var.domain_name}"
}

resource "authentik_group" "harbor-users" {
  name = "harbor-users"
}

resource "authentik_policy_binding" "harbor-users-binding" {
  target = authentik_application.harbor.uuid
  group  = authentik_group.harbor-users.id
  order  = 0
}
