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

resource "tfe_workspace" "talos_proxmox" {
  name         = "talos-proxmox"
  organization = var.organization
  project_id   = tfe_project.this.id
}

resource "tfe_workspace" "talos_system" {
  name         = "talos-system"
  organization = var.organization
  project_id   = tfe_project.this.id
}

resource "tfe_workspace" "talos_base" {
  name         = "talos-base"
  organization = var.organization
  project_id   = tfe_project.this.id
}

resource "tfe_workspace_settings" "talos_proxmox" {
  workspace_id   = tfe_workspace.talos_proxmox.id
  execution_mode = "local"
}

resource "tfe_workspace_settings" "talos_system" {
  workspace_id   = tfe_workspace.talos_system.id
  execution_mode = "local"
}

resource "tfe_workspace_settings" "talos_base" {
  workspace_id   = tfe_workspace.talos_base.id
  execution_mode = "local"
}
