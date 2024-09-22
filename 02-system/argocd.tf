data "helm_template" "argocd" {
  provider         = helm.template
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = "argocd"
  kube_version     = var.talos_kube_version
  values           = []
}
