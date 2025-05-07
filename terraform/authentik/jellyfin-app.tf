resource "authentik_provider_ldap" "jellyfin" {
  name                    = "Jellyfin"
  base_dn                 = "dc=authentik,dc=${replace(var.domain_name, ".", ",dc=")}"
  bind_flow               = data.authentik_flow.default-authentication-flow.id
  unbind_flow             = data.authentik_flow.default-invalidation-flow.id
  mfa_support             = false
}

resource "authentik_application" "jellyfin" {
  name              = "Jellyfin"
  slug              = "jellyfin"
  protocol_provider = authentik_provider_ldap.jellyfin.id
  group             = "media"
  meta_icon         = "https://s3.prizrak.me/media/jellyfin.svg"
  meta_launch_url   = "https://jellyfin.${var.domain_name}"
}

resource "authentik_group" "jellyfin-users" {
  name = "jellyfin-users"
}

resource "authentik_group" "jellyfin-admins" {
  name = "jellyfin-admins"
}

resource "authentik_policy_binding"  "jellyfin-users-binding" {
  target = authentik_application.jellyfin.uuid
  group = authentik_group.jellyfin-users.id
  order = 0
}

resource "authentik_policy_binding"  "jellyfin-admins-binding" {
  target = authentik_application.jellyfin.uuid
  group = authentik_group.jellyfin-admins.id
  order = 0
}
