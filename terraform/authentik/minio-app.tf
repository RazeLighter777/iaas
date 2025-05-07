variable "minio_client_id" {
  description = "The client ID for the minio OAuth2 provider"
}

variable "minio_client_secret" {
  description = "The client secret for the minio OAuth2 provider"
}




resource "authentik_group" "minio-admins" {
    name    = "Minio admins"
}

resource "authentik_group" "minio-users" {
    name    = "Minio users"
}

resource "authentik_property_mapping_provider_scope" "scope-minio" {
  name       = "minio"
  scope_name = "minio"
  expression = <<EOF
return {
  "policy": "readwrite",
}
EOF
}

# signing certificate
data "authentik_certificate_key_pair" "default" {
  name = "authentik Self-signed Certificate"
}
resource "authentik_provider_oauth2" "minio" {
  name          = "Minio"
  client_id     = var.minio_client_id
  client_secret = var.minio_client_secret
  sub_mode = "user_username"
  authorization_flow  = data.authentik_flow.default-authorization-flow.id
  invalidation_flow   = data.authentik_flow.default-provider-invalidation-flow.id
  signing_key    = data.authentik_certificate_key_pair.default.id
  allowed_redirect_uris = [
    {
      matching_mode = "strict"
      url           = "https://minio.${var.domain_name}/oauth_callback"
    }
  ]

  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
    authentik_property_mapping_provider_scope.scope-minio.id
  ]
}


resource "authentik_application" "minio" {
  name              = "Minio"
  slug              = "minio"
  protocol_provider = authentik_provider_oauth2.minio.id
  group             = "storage"
  meta_icon         = "https://s3.prizrak.me/minio.png"
}

resource "authentik_policy_binding" "minio-admins-binding" {
  target = authentik_application.minio.uuid
  group  = authentik_group.minio-admins.id
  order  = 0
}

resource "authentik_policy_binding" "minio-users-binding" {
  target = authentik_application.minio.uuid
  group  = authentik_group.minio-users.id
  order  = 0
}



