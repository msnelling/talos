locals {
  common_machine_config = templatefile("${path.module}/templates/common_config.yaml.tpl", {
    cluster_name = var.talos_cluster_name
    node_name    = "talos" // TODO: Get this each talos node
  })

  controller_machine_config = templatefile("${path.module}/templates/controller_config.yaml.tpl", {
    vip                     = var.talos_controller_vip
    schedule_on_controllers = var.talos_schedule_on_controllers
    gateway_api_version     = var.gateway_api_version

    cilium_values = templatefile("${path.module}/templates/cilium_values.yaml.tpl", {
      loadbalancer_ip = var.cilium_loadbalancer_ip
    })

    cilium_install = templatefile("${path.module}/templates/cilium_install.yaml.tpl", {
      cilium_version = var.cilium_version
    })

    argocd_install = data.helm_template.argocd.manifest
  })
}

resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "this" {
  cluster_name         = var.talos_cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = local.controller_addresses_ipv4
  endpoints            = local.controller_addresses_ipv4
}

data "talos_machine_configuration" "controller" {
  cluster_name       = var.talos_cluster_name
  cluster_endpoint   = "https://${var.talos_controller_vip}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.talos_kube_version
  examples           = false
  docs               = false
  config_patches = [
    local.common_machine_config,
    local.controller_machine_config,
  ]
}

data "talos_machine_configuration" "worker" {
  cluster_name       = var.talos_cluster_name
  cluster_endpoint   = "https://${var.talos_controller_vip}:6443"
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.talos_kube_version
  examples           = false
  docs               = false
  config_patches = [
    local.common_machine_config,
  ]
}

resource "talos_machine_configuration_apply" "controller" {
  for_each = toset(local.controller_addresses_ipv4)

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controller.machine_configuration
  node                        = each.value
}

resource "talos_machine_configuration_apply" "worker" {
  for_each = toset(local.worker_addresses_ipv4)

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value
}

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controller_addresses_ipv4[0]

  depends_on = [
    talos_machine_configuration_apply.controller
  ]
}

/*
data "talos_cluster_health" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  control_plane_nodes  = local.controller_addresses_ipv4
  endpoints            = data.talos_client_configuration.this.endpoints

  depends_on = [
    talos_machine_bootstrap.this,
    talos_machine_configuration_apply.controller,
  ]
}
*/

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controller_addresses_ipv4[0]
  endpoint             = var.talos_controller_vip

  depends_on = [
    talos_machine_bootstrap.this,
    //data.talos_cluster_health.this,
  ]
}

resource "local_sensitive_file" "talosconfig" {
  content  = data.talos_client_configuration.this.talos_config
  filename = "${path.module}/output/talosconfig"
}

resource "local_sensitive_file" "kubeconfig" {
  content  = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = "${path.module}/output/kubeconfig"
}
