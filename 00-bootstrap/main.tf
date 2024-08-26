terraform {
  required_providers {
    tfe = {
      version = "~> 0.58.0"
    }
  }
}

provider "tfe" {
  hostname = var.hostname
  token    = local.tfe_token
}

resource "tfe_workspace" "nodes" {
  name           = "talos_nodes"
  organization   = var.organization
}

resource "tfe_workspace_settings" "nodes-settings" {
  workspace_id   = tfe_workspace.nodes.id
  execution_mode = "local"
}

resource "tfe_workspace" "talos" {
  name           = "talos_install"
  organization   = var.organization
}

resource "tfe_workspace_settings" "talos-settings" {
  workspace_id   = tfe_workspace.talos.id
  execution_mode = "local"
}
