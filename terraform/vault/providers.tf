terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "4.7.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.1"
    }
  }
}


data "sops_file" "vault_secrets" {
  source_file = "vault_secrets.sops.yaml"
}

provider "vault" {
  # Configuration option
  address = data.sops_file.vault_secrets.data["data.address"]
  token = data.sops_file.vault_secrets.data["data.token"]
}

provider "random" {
  # Configuration options
}