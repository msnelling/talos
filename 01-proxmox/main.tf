terraform {
  cloud {
    organization = "xmple"

    workspaces {
      name = "proxmox"
    }
  }

  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.64.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.6.0-beta.0"
    }
  }
}
