resource "vault_policy" "cert_manager" {
  name   = "talos-cert-manager"
  policy = <<-EOT
    path "secret/data/talos/cloudflare/cert-manager/*" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "cert_manager" {
  backend                          = vault_auth_backend.this.path
  role_name                        = "cert-manager"
  bound_service_account_names      = ["cert-manager-external-secrets"]
  bound_service_account_namespaces = ["cert-manager"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.cert_manager.name]
}
