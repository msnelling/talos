resource "vault_policy" "argocd" {
  name   = "talos-argocd"
  policy = <<-EOT
    path "secret/data/*" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "argocd" {
  backend                          = vault_auth_backend.this.path
  role_name                        = "argocd"
  bound_service_account_names      = ["argocd-external-secrets"]
  bound_service_account_namespaces = ["argocd"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.argocd.name]
}
