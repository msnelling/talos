locals {
  cert_sans = concat(
    [
      var.talos_controller_vip_ip,
      var.talos_controller_vip_fqdn,
    ],
    [for name, node in local.controller_nodes : node.address_ipv4]
  )

  common_machine_configs = {
    for name, node in local.all_nodes : name => templatefile("${path.module}/templates/common_config.yaml.tpl", {
      cluster_name   = var.talos_cluster_name
      node_name      = lower(name)
      cilium_enabled = var.cilium_enabled
  }) }

  controller_machine_config = templatefile("${path.module}/templates/controller_config.yaml.tpl", {
    vip_ipv4                = var.talos_controller_vip_ip
    cert_sans               = local.cert_sans
    schedule_on_controllers = var.talos_schedule_on_controllers
    gateway_api_enabled     = var.gateway_api_enabled
    gateway_api_version     = var.gateway_api_version
    argocd_release          = var.argocd_release
    cilium_enabled          = var.cilium_enabled

    cilium_values = templatefile("${path.module}/templates/cilium_values.yaml.tpl", {
      loadbalancer_ip = var.cilium_loadbalancer_ip
    })

    cilium_install = templatefile("${path.module}/templates/cilium_install.yaml.tpl", {
      cilium_version = var.cilium_version
    })

    argocd_install = templatefile("${path.module}/templates/argocd_install.yaml.tpl", {
      argocd_release = var.argocd_release
    })

    argocd_bootstrap = templatefile("${path.module}/templates/argocd_bootstrap.yaml.tpl", {
      // TBD
    })
  })
}

resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "this" {
  cluster_name         = var.talos_cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [for name, node in local.controller_nodes : node.address_ipv4]
  endpoints            = [for name, node in local.controller_nodes : node.address_ipv4]
}

data "talos_machine_configuration" "controller" {
  for_each           = local.controller_nodes
  cluster_name       = var.talos_cluster_name
  cluster_endpoint   = "https://${each.value.address_ipv4}:6443"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.talos_kube_version
  examples           = false
  docs               = false
  config_patches = [
    local.common_machine_configs[each.key],
    local.controller_machine_config,
  ]
}

data "talos_machine_configuration" "worker" {
  for_each           = local.worker_nodes
  cluster_name       = var.talos_cluster_name
  cluster_endpoint   = "https://${each.value.address_ipv4}:6443"
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.talos_kube_version
  examples           = false
  docs               = false
  config_patches = [
    local.common_machine_configs[each.key],
  ]
}

resource "talos_machine_configuration_apply" "controller" {
  for_each                    = local.controller_nodes
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controller[each.key].machine_configuration
  node                        = each.value.address_ipv4
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = local.worker_nodes
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[each.key].machine_configuration
  node                        = each.value.address_ipv4
}

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.bootstrap_address_ipv4

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
  node                 = local.bootstrap_address_ipv4

  depends_on = [
    talos_machine_bootstrap.this,
    //data.talos_cluster_health.this,
  ]
}

resource "local_sensitive_file" "talosconfig" {
  content = data.talos_client_configuration.this.talos_config
  #filename = "${path.module}/output/talosconfig"
  filename = var.talos_config_file
}

resource "local_sensitive_file" "kubeconfig" {
  content = talos_cluster_kubeconfig.this.kubeconfig_raw
  #filename = "${path.module}/output/kubeconfig"
  filename = var.kubeconfig_file
}
