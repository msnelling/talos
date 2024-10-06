/*
resource "kubernetes_manifest" "argocd_bootstrap_appproject" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "AppProject"
    "metadata" = {
      "name"       = "bootstrap"
      "namespace"  = "argocd"
      "finalizers" = ["resources-finalizer.argocd.argoproj.io"]
    }
    "spec" = {
      "description" = "Bootstrap Project"
      "sourceRepos" = ["*"]
      "destinations" = [
        {
          "namespace" = "*"
          "server"    = "*"
        }
      ]
      "clusterResourceWhitelist" = [
        {
          "group" = "*"
          "kind"  = "*"
        }
      ]
      "clusterResourceBlacklist" = [
        {
          "group" = "cilium.io"
          "kind"  = "CiliumIdentity"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "argocd_bootstrap_application" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"       = "bootstrap"
      "namespace"  = "argocd"
      "finalizers" = ["resources-finalizer.argocd.argoproj.io"]
    }
    "spec" = {
      "project" = "bootstrap"
      "source" = {
        "repoURL"        = "https://github.com/msnelling/argocd-bootstrap.git"
        "path"           = "01-bootstrap"
        "targetRevision" = "talos"
      }
      "destination" = {
        "name"      = "in-cluster"
        "namespace" = "argocd"
      }
      "syncPolicy" = {
        "automated" = {}
        "retry" = {
          "limit" = 10
          "backoff" = {
            "duration"    = "10s"
            "factor"      = 2
            "maxDuration" = "3m"
          }
        }
      }
    }
  }
}
*/

resource "vault_policy" "argocd" {
  name   = "talos-argocd"
  policy = <<-EOT
    path "secret/data/*" {
      capabilities = ["read"]
    }
  EOT
}

resource "vault_kubernetes_auth_backend_role" "argocd" {
  backend                          = vault_auth_backend.this.path
  role_name                        = "argocd"
  bound_service_account_names      = ["argocd-external-secrets"]
  bound_service_account_namespaces = ["argocd"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.argocd.name]
}

resource "vault_kubernetes_auth_backend_role" "external_secrets" {
  backend                          = vault_auth_backend.this.path
  role_name                        = "external-secrets"
  bound_service_account_names      = ["vault-external-secrets"]
  bound_service_account_namespaces = ["argocd"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.argocd.name]
}
