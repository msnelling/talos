data "helm_template" "cilium" {
  provider     = helm.template
  name         = "cilium"
  chart        = "cilium"
  version      = var.cilium_version
  repository   = "https://helm.cilium.io"
  namespace    = "kube-system"
  kube_version = var.talos_kube_version

  values = [
    file("${path.module}/templates/cilium_values.yaml")
  ]
}
