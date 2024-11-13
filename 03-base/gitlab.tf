resource "vault_policy" "gitlab" {
  name   = "talos-gitlab"
  policy = <<-EOT
    path "secret/data/gitlab/*" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "gitlab" {
  backend                          = vault_auth_backend.this.path
  role_name                        = "gitlab"
  bound_service_account_names      = ["*"]
  bound_service_account_namespaces = ["gitlab"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.gitlab.name]
}
