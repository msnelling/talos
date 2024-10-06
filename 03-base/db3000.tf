resource "vault_policy" "db3000" {
  name   = "talos-db3000"
  policy = <<-EOT
    path "secret/data/db3000/*" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "db3000" {
  backend                          = vault_auth_backend.this.path
  role_name                        = "db3000"
  bound_service_account_names      = ["*"]
  bound_service_account_namespaces = ["db3000"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.db3000.name]
}
