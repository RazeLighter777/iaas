# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "cbca752b-46e3-4a17-bf04-3539e434abb5"
resource "opnsense_route" "route_192_168_87_0_24" {
  description = "wireguard"
  enabled     = true
  gateway     = "wg0"
  network     = "192.168.87.0/24"
}

# __generated__ by Terraform from "__opt3_network"
resource "opnsense_firewall_alias" "opt3_network" {
  categories  = []
  content     = []
  description = "lanbridge net"
  enabled     = true
  ip_protocol = []
  name        = "__opt3_network"
  stats       = false
  type        = "internal"
  update_freq = -1
}

# __generated__ by Terraform from "sshlockout"
resource "opnsense_firewall_alias" "sshlockout" {
  categories  = []
  content     = []
  description = "abuse lockout table (internal)"
  enabled     = true
  ip_protocol = []
  name        = "sshlockout"
  stats       = false
  type        = "external"
  update_freq = -1
}

# __generated__ by Terraform from "bogons"
resource "opnsense_firewall_alias" "bogons" {
  categories  = []
  content     = []
  description = "bogon networks (internal)"
  enabled     = true
  ip_protocol = []
  name        = "bogons"
  stats       = false
  type        = "external"
  update_freq = -1
}

# __generated__ by Terraform from "4e29bf97-2278-4a82-9fa2-27d927a1dc96"
resource "opnsense_firewall_alias" "wan_network" {
  categories  = []
  content     = ["__wan_network"]
  description = null
  enabled     = true
  ip_protocol = []
  name        = "wan_network"
  stats       = false
  type        = "host"
  update_freq = -1
}

# __generated__ by Terraform from "__lo0_network"
resource "opnsense_firewall_alias" "lo0_network" {
  categories  = []
  content     = []
  description = "Loopback net"
  enabled     = true
  ip_protocol = []
  name        = "__lo0_network"
  stats       = false
  type        = "internal"
  update_freq = -1
}

# __generated__ by Terraform from "269d5ef0-5d26-4c21-be9a-4c4d527645e2"
resource "opnsense_firewall_alias" "servernet" {
  categories  = []
  content     = ["192.168.88.0/24"]
  description = null
  enabled     = true
  ip_protocol = []
  name        = "servernet"
  stats       = false
  type        = "network"
  update_freq = -1
}

# __generated__ by Terraform from "f83df8ca-a0e6-4cf5-9bc5-8287b89f73f5"
resource "opnsense_firewall_alias" "wifi" {
  categories  = []
  content     = ["10.10.10.0/24"]
  description = null
  enabled     = true
  ip_protocol = []
  name        = "wifi"
  stats       = false
  type        = "network"
  update_freq = -1
}

# __generated__ by Terraform from "virusprot"
resource "opnsense_firewall_alias" "virusprot" {
  categories  = []
  content     = []
  description = "overload table for rate limiting (internal)"
  enabled     = true
  ip_protocol = []
  name        = "virusprot"
  stats       = false
  type        = "external"
  update_freq = -1
}

# __generated__ by Terraform from "b1ba1bf2-f3a7-4fd0-8dcf-d548637b2cf9"
resource "opnsense_wireguard_client" "wg_client_edge" {
  enabled        = true
  keep_alive     = 25
  name           = "edge"
  psk            = null # sensitive
  public_key     = "VzQMzZcTBQYrARnefqraQJuc6CVFf15ifUNsDuTV2wY="
  server_address = "edge.prizrak.me"
  server_port    = 51820
  tunnel_address = ["192.168.87.0/24"]
}

# __generated__ by Terraform from "defb5942-580f-4350-9937-ea9c2fe15b36"
resource "opnsense_route" "route_10_10_10_0_24" {
  description = "brocade wifi route"
  enabled     = true
  gateway     = "brocade_l3"
  network     = "10.10.10.0/24"
}

# __generated__ by Terraform from "a8e5c766-5a86-46aa-83fe-26c32486e74d"
resource "opnsense_route" "route_192_168_84_0_24" {
  description = "iot brocade route"
  enabled     = true
  gateway     = "brocade_l3"
  network     = "192.168.84.0/24"
}

# __generated__ by Terraform from "__opt1_network"
resource "opnsense_firewall_alias" "opt1_network" {
  categories  = []
  content     = []
  description = "prizrakvpn net"
  enabled     = true
  ip_protocol = []
  name        = "__opt1_network"
  stats       = false
  type        = "internal"
  update_freq = -1
}

# __generated__ by Terraform from "__wireguard_network"
resource "opnsense_firewall_alias" "wireguard_network" {
  categories  = []
  content     = []
  description = "WireGuard (Group) net"
  enabled     = true
  ip_protocol = []
  name        = "__wireguard_network"
  stats       = false
  type        = "internal"
  update_freq = -1
}

# __generated__ by Terraform from "__opt2_network"
resource "opnsense_firewall_alias" "opt2_network" {
  categories  = []
  content     = []
  description = "sfp_lan net"
  enabled     = true
  ip_protocol = []
  name        = "__opt2_network"
  stats       = false
  type        = "internal"
  update_freq = -1
}

# __generated__ by Terraform from "__wan_network"
resource "opnsense_firewall_alias" "wan_network_1" {
  categories  = []
  content     = []
  description = "wan net"
  enabled     = true
  ip_protocol = []
  name        = "__wan_network"
  stats       = false
  type        = "internal"
  update_freq = -1
}

# __generated__ by Terraform from "bogonsv6"
resource "opnsense_firewall_alias" "bogonsv6" {
  categories  = []
  content     = []
  description = "bogon networks IPv6 (internal)"
  enabled     = true
  ip_protocol = []
  name        = "bogonsv6"
  stats       = false
  type        = "external"
  update_freq = -1
}
