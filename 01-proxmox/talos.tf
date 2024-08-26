provider "talos" {}

resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [var.talos_cp1_ip_addr]
}

data "talos_machine_configuration" "machineconfig_cp" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp1_ip_addr}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

resource "talos_machine_configuration_apply" "cp_config_apply" {
  depends_on = [
    proxmox_virtual_environment_vm.talos_cp1
  ]

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
  count                       = 1
  node                        = var.talos_cp1_ip_addr
}

data "talos_machine_configuration" "machineconfig_worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp1_ip_addr}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

resource "talos_machine_configuration_apply" "worker_config_apply" {
  depends_on = [
    proxmox_virtual_environment_vm.talos_worker1
  ]

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker.machine_configuration
  count                       = 1
  node                        = var.talos_worker1_ip_addr
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.cp_config_apply
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.talos_cp1_ip_addr
}

data "talos_cluster_health" "health" {
  depends_on = [
    talos_machine_configuration_apply.cp_config_apply,
    talos_machine_configuration_apply.worker_config_apply
  ]

  client_configuration = data.talos_client_configuration.talosconfig.client_configuration
  control_plane_nodes  = [var.talos_cp1_ip_addr]
  worker_nodes         = [var.talos_worker1_ip_addr]
  endpoints            = data.talos_client_configuration.talosconfig.endpoints
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this,
    data.talos_cluster_health.health
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.talos_cp1_ip_addr
}