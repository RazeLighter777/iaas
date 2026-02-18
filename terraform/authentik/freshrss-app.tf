variable "freshrss_client_id" {
  description = "The client ID for the FreshRSS OAuth2 provider"
}

variable "freshrss_client_secret" {
  description = "The client secret for the FreshRSS OAuth2 provider"
}

resource "authentik_provider_oauth2" "freshrss" {
  name          = "FreshRSS"
  client_id     = var.freshrss_client_id
  client_secret = var.freshrss_client_secret

  authorization_flow  = data.authentik_flow.default-authorization-flow.id
  invalidation_flow   = data.authentik_flow.default-provider-invalidation-flow.id
  signing_key         = data.authentik_certificate_key_pair.default.id

  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "https://rss.${var.domain_name}/i/oidc/callback"
    }
  ]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
  ]
}

resource "authentik_application" "freshrss" {
  name              = "FreshRSS"
  slug              = "freshrss"
  protocol_provider = authentik_provider_oauth2.freshrss.id
  group             = "productivity"
  meta_icon         = "https://s3.${var.domain_name}/media/freshrss.png"
  meta_launch_url   = "https://rss.${var.domain_name}"
}

resource "authentik_group" "freshrss-users" {
  name = "freshrss-users"
}

resource "authentik_policy_binding" "freshrss-users-binding" {
  target = authentik_application.freshrss.id
  group  = authentik_group.freshrss-users.id
  order  = 0
}
