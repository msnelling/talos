terraform {
  required_version = ">= 1.0"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "xmple"
    workspaces {
      name = "talos_nodes"
    }
  }

  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.63.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.6.0-alpha.1"
    }
  }
}
