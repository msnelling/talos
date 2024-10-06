locals {
  kubeconfig_server             = data.vault_generic_secret.kubeconfig.data["server"]
  kubeconfig_ca_certificate     = base64decode(data.vault_generic_secret.kubeconfig.data["ca_certificate"])
  kubeconfig_client_certificate = base64decode(data.vault_generic_secret.kubeconfig.data["client_certificate"])
  kubeconfig_client_key         = base64decode(data.vault_generic_secret.kubeconfig.data["client_key"])

  cloudflare_admin_token = data.vault_generic_secret.cloudflare_admin.data["api-token"]
  cloudflare_account_id  = data.vault_generic_secret.cloudflare_admin.data["account-id"]
}

data "vault_generic_secret" "kubeconfig" {
  path = "secret/talos/kubeconfig"
}

data "vault_generic_secret" "cloudflare_admin" {
  path = "secret/talos/cloudflare/admin"
}
