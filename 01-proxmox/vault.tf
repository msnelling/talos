provider "vault" {
}

data "vault_generic_secret" "proxmox_provider" {
  path = "secret/proxmox/terraform-provider"
}

locals {
  vault_secret_proxmox_username   = data.vault_generic_secret.proxmox_provider.data["username"]
  vault_secret_proxmox_token_name = data.vault_generic_secret.proxmox_provider.data["token-name"]
  vault_secret_proxmox_token      = data.vault_generic_secret.proxmox_provider.data["token"]
}