terraform {
  cloud {
    organization = "xmple"

    workspaces {
      name = "talos-proxmox"
    }
  }

  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.8"
    }
    netparse = {
      source = "gmeligio/netparse"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = "${local.vault_secret_proxmox_username}!${local.vault_secret_proxmox_token_name}=${local.vault_secret_proxmox_token}"

  ssh {
    username = "root"
    password = local.vault_secret_proxmox_root_password
  }
}

provider "talos" {}

provider "vault" {}

provider "netparse" {}