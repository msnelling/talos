terraform {
  cloud {
    organization = "xmple"

    workspaces {
      name = "talos-system"
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
  workspace    = "talos-proxmox"
}

provider "talos" {}

provider "vault" {}

provider "helm" {
  kubernetes {
    host                   = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
    client_certificate     = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate
    client_key             = talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key
    cluster_ca_certificate = talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate
  }
}
