data "cloudflare_api_token_permission_groups_list" "all" {}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "this" {
  account_id = local.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id
}

locals {
  # https://developers.cloudflare.com/fundamentals/api/reference/permissions/#zone-permissions
  api_token_zone_permissions_groups_map = {
    for perm in data.cloudflare_api_token_permission_groups_list.all.result :
    perm.name => perm.id
    if contains(perm.scopes, "com.cloudflare.api.account.zone")
  }
}

resource "cloudflare_api_token" "cert_manager_issuer" {
  name   = "Talos Certificate Issuer"
  status = "active"
  policies = [{
    effect = "allow"
    resources = {
      "com.cloudflare.api.account.${local.cloudflare_account_id}" = "*"
    }
    permission_groups = [
      { id = local.api_token_zone_permissions_groups_map["Zone Read"] },
      { id = local.api_token_zone_permissions_groups_map["DNS Write"] },
    ]
  }]
}

resource "vault_generic_secret" "cert_manager_issuer_token" {
  path      = "secret/talos/cloudflare/cert-manager/issuer"
  data_json = <<-EOT
    {
      "api-token": "${cloudflare_api_token.cert_manager_issuer.value}"
    }
  EOT
}

resource "random_bytes" "cloudflare_tunnel_password" {
  length = 64
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "this" {
  account_id    = local.cloudflare_account_id
  name          = "talos"
  config_src    = "cloudflare"
  tunnel_secret = random_bytes.cloudflare_tunnel_password.base64
}

resource "vault_generic_secret" "tunnel_token" {
  path      = "secret/talos/cloudflare/tunnels/system"
  data_json = <<-EOT
    {
      "tunnel-token": "${data.cloudflare_zero_trust_tunnel_cloudflared_token.this.token}"
    }
  EOT
}

resource "vault_policy" "cloudflare_tunnels" {
  name   = "talos-cloudflare-tunnels"
  policy = <<-EOT
    path "secret/data/talos/cloudflare/tunnels/*" {
      capabilities = ["read"]
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
