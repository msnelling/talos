resource "vault_policy" "authelia" {
  name   = "talos-authelia"
  policy = <<-EOT
    path "secret/data/authelia" {
      capabilities = ["read"]
    }
    path "secret/data/authelia.json" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "authelia" {
  backend                          = vault_auth_backend.this.path
  role_name                        = "authelia"
  bound_service_account_names      = ["authelia-external-secrets"]
  bound_service_account_namespaces = ["authelia"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.authelia.name]
}
