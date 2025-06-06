terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
    }
  }
}

variable "name" {
  type = string
}
variable "slug" {
  type    = string
  default = null
}
variable "domain_name" {
  type = string
}
variable "access_token_validity" {
  type    = string
  default = "weeks=8"
}
variable "authentication_flow_uuid" {
  type    = string
  default = null
}
variable "authorization_flow_uuid" {
  type = string
}

variable "meta_icon" {
  type    = string
  default = null
}
variable "meta_launch_url" {
  type    = string
  default = null
}
variable "group" {
  type = string
}
variable "policy_engine_mode" {
  type    = string
  default = "all"
}

variable "mode" {
  type    = string
  default = "forward_single"
}
variable "open_in_new_tab" {
  type    = bool
  default = true
}

variable "internal_host" {
  type    = string
  default = null
}
variable "basic_auth_enabled" {
  type    = bool
  default = false
}
variable "basic_auth_password_attribute" {
  type    = string
  default = null
}
variable "basic_auth_username_attribute" {
  type    = string
  default = null
}

variable "property_mappings" {
  type    = list(string)
  default = null
}
variable "skip_path_regex" {
  type    = string
  default = null
}

data "authentik_flow" "default-provider-invalidation-flow" {
  slug = "default-provider-invalidation-flow"
}

resource "authentik_provider_proxy" "main" {
  name                          = var.name
  external_host                 = "https://${var.domain_name}"
  internal_host                 = var.internal_host
  basic_auth_enabled            = var.basic_auth_enabled
  basic_auth_password_attribute = var.basic_auth_password_attribute
  basic_auth_username_attribute = var.basic_auth_username_attribute
  mode                          = var.mode
  authentication_flow           = var.authentication_flow_uuid
  authorization_flow            = var.authorization_flow_uuid
  invalidation_flow             = data.authentik_flow.default-provider-invalidation-flow.id
  access_token_validity         = var.access_token_validity
  property_mappings             = var.property_mappings
  skip_path_regex               = var.skip_path_regex
}


resource "authentik_application" "main" {
  name               = title(var.name)
  slug               = coalesce(var.slug, var.name)
  protocol_provider  = authentik_provider_proxy.main.id
  group              = var.group
  open_in_new_tab    = var.open_in_new_tab
  meta_icon          = var.meta_icon
  meta_launch_url    = var.meta_launch_url
  policy_engine_mode = var.policy_engine_mode
}

output "application_id" {
  value = authentik_application.main.uuid
}
output "proxy_provider_id" {
  value = authentik_provider_proxy.main.id
}