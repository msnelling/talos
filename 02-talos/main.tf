terraform {
  cloud {
    organization = "xmple"

    workspaces {
      name = "talos"
    }
  }

  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.6.0-beta.0"
    }
  }
}

data "tfe_outputs" "proxmox" {
  organization = "xmple"
  workspace    = "proxmox"
}
