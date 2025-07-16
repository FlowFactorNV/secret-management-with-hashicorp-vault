terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.0.0"
    }
  }
}

provider "vault" {
  address = var.vault_address # or use environment variable VAULT_ADDR
  token   = var.vault_token # or use environment variable VAULT_TOKEN
}
