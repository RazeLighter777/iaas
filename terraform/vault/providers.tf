terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "4.8.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
  }
}


variable "VAULT_ADDR" {
  type = string
}

variable "VAULT_TOKEN" {
  type = string
}

provider "vault" {
  # Configuration option
  address = var.VAULT_ADDR
  token = var.VAULT_TOKEN
}

provider "random" {
  # Configuration options
}