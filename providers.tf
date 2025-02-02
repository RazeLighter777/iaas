terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.70.1"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.7.1"
    }
    sops = {
      source = "carlpett/sops"
      version = "~> 0.5"
    }
  }
}

data "sops_file" "proxmox_secrets" {
  source_file = "proxmox_secrets.sops.yaml"
}


provider "proxmox" {
  endpoint   = data.sops_file.proxmox_secrets.data["data.api_url"]
  username      = data.sops_file.proxmox_secrets.data["data.username"]
  password  = data.sops_file.proxmox_secrets.data["data.password"]
  insecure = true
  ssh {
    agent = true
    username = data.sops_file.proxmox_secrets.data["data.username"]
  }
}
