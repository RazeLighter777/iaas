
resource "authentik_provider_ldap" "jellyfin" {
  name                    = "Jellyfin LDAP"
  base_dn                 = "dc=authentik,dc=${replace(var.domain_name, ".", ",dc=")}"
  bind_flow               = data.authentik_flow.default-authentication-flow.id
  search_group            = null
  certificate             = null
  
  # LDAP specific settings
  bind_mode               = "direct"
  mfa_support             = false
  
  # User and group search settings
  object_uniqueness_field = "uid"
  user_path_template      = "goauthentik.io/users/%(username)s"
  
  # Attribute mappings
  property_mappings_group = []
  property_mappings_user  = [
    data.authentik_property_mapping_ldap.name.id,
    data.authentik_property_mapping_ldap.email.id,
    data.authentik_property_mapping_ldap.uid.id
  ]
}

resource "authentik_property_mapping_ldap" "name" {
  name         = "custom-field"
  object_field = "username"
  expression   = "return ldap.get('sAMAccountName')"
}

resource "authentik_property_mapping_ldap" "email" {
  name         = "custom-field"
  object_field = "email"
  expression   = "return ldap.get('mail')"
}

resource "authentik_property_mapping_ldap" "uid" {
  name         = "custom-field"
  object_field = "uid"
  expression   = "return ldap.get('uid')"
}

resource "authentik_application" "jellyfin" {
  name              = "Jellyfin"
  slug              = "jellyfin"
  protocol_provider = authentik_provider_ldap.jellyfin.id
  group             = "media"
  meta_icon         = "https://jellyfin.org/images/logo.svg"
  meta_launch_url   = "https://jellyfin.${var.domain_name}"
}

resource "authentik_group" "jellyfin-users" {
  name = "jellyfin-users"
}

resource "authentik_policy_binding" "jellyfin-users-binding" {
  target = authentik_application.jellyfin.uuid
  group  = authentik_group.jellyfin-users.id
  order  = 0
}
