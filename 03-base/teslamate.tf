resource "vault_policy" "teslamate" {
  name   = "talos-teslamate"
  policy = <<-EOT
    path "secret/data/teslamate/*" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "teslamate" {
  backend                          = vault_auth_backend.this.path
  role_name                        = "teslamate"
  bound_service_account_names      = ["teslamate-external-secrets"]
  bound_service_account_namespaces = ["teslamate"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.teslamate.name]
}
