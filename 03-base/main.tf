terraform {
  cloud {
    organization = "xmple"

    workspaces {
      name = "talos-base"
    }
  }

  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

data "tfe_outputs" "talos_system" {
  organization = "xmple"
  workspace    = "talos-system"
}

provider "vault" {}

provider "kubernetes" {
  host                   = local.kubeconfig_server
  cluster_ca_certificate = local.kubeconfig_ca_certificate
  client_certificate     = local.kubeconfig_client_certificate
  client_key             = local.kubeconfig_client_key
}

provider "cloudflare" {
  api_token = local.cloudflare_admin_token
}
