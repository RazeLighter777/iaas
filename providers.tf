terraform {
  required_providers {
    proxmox = {
      source = "Terraform-for-Proxmox/proxmox"
      version = "0.0.1"
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
  pm_api_url   = data.sops_file.tf_secrets.data["data.pm_api_url"]
  pm_user      = data.sops_file.tf_secrets.data["data.pm_user"]
  pm_password  = data.sops_file.tf_secrets.data["data.pm_password"]
}
