provider "vault" {
}

data "vault_generic_secret" "proxmox_provider" {
  path = "secret/proxmox/terraform-provider"
}

locals {
  vault_secret_proxmox_username   = data.vault_generic_secret.proxmox_provider.data["username"]
  vault_secret_proxmox_token_name = data.vault_generic_secret.proxmox_provider.data["token-name"]
  vault_secret_proxmox_token      = data.vault_generic_secret.proxmox_provider.data["token"]
}

resource "vault_generic_secret" "kubeconfig" {
  path      = "secret/talos/kubeconfig"
  data_json = <<-EOT
  {
    "ca_certificate": "${talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate}",
    "client_certificate": "${talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate}",
    "client_key": "${talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key}",
    "server": "${talos_cluster_kubeconfig.this.kubernetes_client_configuration.host}"
  }
  EOT
}
