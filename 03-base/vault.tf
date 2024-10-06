locals {
  vault_namespace             = kubernetes_namespace_v1.vault.metadata[0].name
  vault_service_account       = kubernetes_service_account_v1.vault.metadata[0].name
  vault_service_account_token = kubernetes_secret_v1.vault_service_account_token.metadata[0].name
}

resource "kubernetes_namespace_v1" "vault" {
  metadata {
    name = "vault"
    labels = {
      "kubernetes.io/metadata.name" = "vault"
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
    annotations = {
      "argocd.argoproj.io/sync-wave" = "-1"
    }
  }
}

resource "kubernetes_service_account_v1" "vault" {
  metadata {
    name      = var.vault_service_account
    namespace = local.vault_namespace
  }
}

resource "kubernetes_secret_v1" "vault_service_account_token" {
  metadata {
    name      = var.vault_service_account_token
    namespace = local.vault_namespace
    annotations = {
      "kubernetes.io/service-account.name"      = local.vault_service_account
      "kubernetes.io/service-account.namespace" = local.vault_namespace
    }
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role_binding_v1" "vault_auth_token_review" {
  metadata {
    name = "vault-auth-tokenreview"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.vault_service_account
    namespace = local.vault_namespace
  }
}

resource "vault_auth_backend" "this" {
  type = "kubernetes"
  path = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "this" {
  backend            = vault_auth_backend.this.path
  kubernetes_host    = local.kubeconfig_server
  kubernetes_ca_cert = kubernetes_secret_v1.vault_service_account_token.data["ca.crt"]
  token_reviewer_jwt = kubernetes_secret_v1.vault_service_account_token.data["token"]

  # Need a more secure way than this
  disable_iss_validation = "true"
  #issuer = "https://kubernetes.default.svc.cluster.local"
}
