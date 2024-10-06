resource "vault_policy" "longhorn" {
  name   = "talos-longhorn"
  policy = <<-EOT
    path "secret/data/s3/minio/root" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "longhorn" {
  backend                          = vault_auth_backend.this.path
  role_name                        = "longhorn"
  bound_service_account_names      = ["longhorn-external-secrets"]
  bound_service_account_namespaces = ["longhorn-system"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.longhorn.name]
}
