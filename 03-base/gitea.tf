resource "vault_policy" "gitea" {
  name   = "talos-gitea"
  policy = <<-EOT
    path "secret/data/gitea/*" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "gitea" {
  backend                          = vault_auth_backend.this.path
  role_name                        = "gitea"
  bound_service_account_names      = ["*"]
  bound_service_account_namespaces = ["gitea"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.gitea.name]
}
