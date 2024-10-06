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
      version = "~> 0.6.0"
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
    agent    = true
    username = "root"
  }
}

provider "talos" {}

provider "vault" {}

provider "netparse" {}