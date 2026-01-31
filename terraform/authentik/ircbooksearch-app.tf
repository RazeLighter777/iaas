module "ircbooksearch" {
  source = "./modules/forward-auth-application"
  slug   = "ircbooksearch"

  name   = "ircbooksearch"
  domain_name = "ircbooksearch.${var.domain_name}"
  group  = "media"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  skip_path_regex         = "/health"

  meta_icon = "https://s3.${var.domain_name}/media/calibre.png"
}

resource "authentik_policy_binding" "ircbooksearch-users-binding" {
  target = module.ircbooksearch.application_id
  group = authentik_group.ircbooksearch-users.id
  order = 0
}