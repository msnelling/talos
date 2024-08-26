terraform {
  required_providers {
    tfe = {
      version = "~> 0.58.1"
    }
  }
}

provider "tfe" {
  hostname = var.hostname
  token    = local.tfe_token
}

resource "tfe_project" "this" {
  name         = "Talos"
  organization = var.organization
}

resource "tfe_workspace" "proxmox" {
  name         = "proxmox"
  organization = var.organization
  project_id   = tfe_project.this.id
}

resource "tfe_workspace_settings" "proxmox_settings" {
  workspace_id   = tfe_workspace.proxmox.id
  execution_mode = "local"
}
