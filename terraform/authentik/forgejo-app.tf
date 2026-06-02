variable "forgejo_client_id" {
  description = "The client ID for the Forgejo OAuth2 provider"
}

variable "forgejo_client_secret" {
  description = "The client secret for the Forgejo OAuth2 provider"
}

resource "authentik_provider_oauth2" "forgejo" {
  name          = "Forgejo"
  client_id     = var.forgejo_client_id
  client_secret = var.forgejo_client_secret

  authorization_flow = data.authentik_flow.default-authorization-flow.id
  invalidation_flow  = data.authentik_flow.default-provider-invalidation-flow.id
  signing_key        = data.authentik_certificate_key_pair.default.id

  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "https://git.${var.domain_name}/user/oauth2/Authentik/callback"
    }
  ]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
  ]
}

resource "authentik_application" "forgejo" {
  name              = "Forgejo"
  slug              = "forgejo"
  protocol_provider = authentik_provider_oauth2.forgejo.id
  group             = "infrastructure"
  meta_icon         = "https://s3.${var.domain_name}/media/forgejo.png"
  meta_launch_url   = "https://git.${var.domain_name}"
}

resource "authentik_group" "forgejo-users" {
  name = "forgejo-users"
}

resource "authentik_group" "forgejo-admins" {
  name = "forgejo-admins"
}

resource "authentik_policy_binding" "forgejo-users-binding" {
  target = authentik_application.forgejo.uuid
  group  = authentik_group.forgejo-users.id
  order  = 0
}

resource "authentik_policy_binding" "forgejo-admins-binding" {
  target = authentik_application.forgejo.uuid
  group  = authentik_group.forgejo-admins.id
  order  = 1
}
