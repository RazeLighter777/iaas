resource "authentik_property_mapping_provider_scope" "scope-groups" {
  name        = "OAuth Mapping: OpenID 'groups'"
  scope_name  = "groups"
  description = "Adds the user's Authentik group names under the 'groups' claim."
  expression  = <<-EOT
    return {
      "groups": [group.name for group in user.ak_groups.all()],
    }
  EOT
}
