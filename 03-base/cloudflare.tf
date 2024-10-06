data "cloudflare_api_token_permission_groups" "all" {}

resource "cloudflare_api_token" "cert_manager_issuer" {
  name = "Talos Certificate Issuer"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.zone["DNS Write"],
      data.cloudflare_api_token_permission_groups.all.zone["Zone Read"],
    ]
    resources = {
      "com.cloudflare.api.account.zone.*" = "*"
    }
  }
}

resource "vault_generic_secret" "cert_manager_issuer_token" {
  path      = "secret/talos/cloudflare/cert-manager/issuer"
  data_json = <<-EOT
    {
      "api-token": "${cloudflare_api_token.cert_manager_issuer.value}"
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "cloudflare_tunnel" {
  backend                          = vault_auth_backend.this.path
  role_name                        = "cloudflare-tunnel"
  bound_service_account_names      = ["cloudflare-tunnel"]
  bound_service_account_namespaces = ["cloudflare"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.cloudflare_tunnels.name]
}

resource "random_bytes" "cloudflare_tunnel_password" {
  length = 64
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "this" {
  account_id = local.cloudflare_account_id
  name       = "talos"
  secret     = random_bytes.cloudflare_tunnel_password.base64
}

resource "vault_generic_secret" "tunnel_token" {
  path      = "secret/talos/cloudflare/tunnel"
  data_json = <<-EOT
    {
      "tunnel-token": "${cloudflare_zero_trust_tunnel_cloudflared.this.tunnel_token}"
    }
  EOT
}

resource "vault_policy" "cloudflare_tunnels" {
  name   = "talos-cloudflare-tunnels"
  policy = <<-EOT
    path "secret/data/talos/cloudflare/tunnel/*" {
      capabilities = ["read"]
    }
  EOT
}
