resource "vault_policy" "tailscale" {
  name   = "talos-tailscale"
  policy = <<-EOT
    path "secret/data/tailscale/*" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "tailscale" {
  backend                          = vault_auth_backend.this.path
  role_name                        = "tailscale"
  bound_service_account_names      = ["tailscale-external-secrets"]
  bound_service_account_namespaces = ["tailscale"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.tailscale.name]
}
