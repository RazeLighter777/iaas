module "wg" {
  source = "./modules/forward-auth-application"
  slug   = "wg-easy"

  name   = "Wg-easy"
  domain_name = "wg.${var.domain_name}"
  group  = "networking"

  policy_engine_mode      = "any"
  authorization_flow_uuid = data.authentik_flow.default-authorization-flow.id
  # no health check :(
  #skip_path_regex         = "/health"

  meta_icon = "https://static-00.iconduck.com/assets.00/wireguard-icon-1024x1024-78n6jncy.png"
}

resource "authentik_group" "wg-users" {
  name = "wg-users"
}

resource "authentik_policy_binding" "wg-users-binding" {
  target = module.wg.application_id
  group = authentik_group.wg-users.id
  order = 0
}