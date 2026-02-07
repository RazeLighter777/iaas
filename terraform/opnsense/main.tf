# =============================================================================
# OPNsense Terraform Module
#
# Manages OPNsense resources: firewall aliases, categories, filter rules,
# NAT rules, interfaces (VLANs, VIPs), routes, and WireGuard.
#
# Import workflow:
#   1. Run: scripts/opnsense_import.sh
#      This queries the OPNsense API, generates imports.tf, then runs
#      terraform plan -generate-config-out=generated.tf
#   2. Review generated.tf and imports.tf
#   3. Run: terraform apply
# =============================================================================

output "opnsense_router_ip" {
  value       = var.OPNSENSE_ROUTER_IP
  description = "OPNsense router IP address"
}

# WireGuard server must be defined here (not auto-generated) because the
# private_key is sensitive and cannot be read back from the OPNsense API.
resource "opnsense_wireguard_server" "wg_server_princessbelongsto_me" {
  disable_routes = false
  dns            = []
  enabled        = true
  mtu            = -1
  name           = "princessbelongsto.me"
  peers          = ["b1ba1bf2-f3a7-4fd0-8dcf-d548637b2cf9"]
  port           = 51820
  private_key    = var.OPNSENSE_WIREGUARD_PRIVATE_KEY
  public_key     = "660YgkEg/qyp5ejMimyFubZFHPnLA6UgdsEV2Vsy2jY="
  tunnel_address = ["192.168.87.6/24"]
}
