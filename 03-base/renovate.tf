resource "vault_policy" "renovate" {
  name   = "talos-renovate"
  policy = <<-EOT
    path "secret/data/renovate/*" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "renovate" {
  backend                          = vault_auth_backend.this.path
  role_name                        = "renovate"
  bound_service_account_names      = ["renovate-external-secrets"]
  bound_service_account_namespaces = ["renovate"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.renovate.name]
}
