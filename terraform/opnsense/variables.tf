variable "OPNSENSE_API_KEY" {
  type        = string
  sensitive   = true
  description = "OPNsense API key for authentication"
}

variable "OPNSENSE_API_SECRET" {
  type        = string
  sensitive   = true
  description = "OPNsense API secret for authentication"
}

variable "OPNSENSE_ROUTER_IP" {
  type        = string
  description = "OPNsense router IP address"
}

variable "OPNSENSE_WIREGUARD_PRIVATE_KEY" {
  type        = string
  sensitive   = true
  description = "WireGuard server private key"
}
