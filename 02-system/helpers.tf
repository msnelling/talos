locals {
  controller_nodes       = data.tfe_outputs.talos_proxmox.nonsensitive_values["controller_nodes"]
  worker_nodes           = data.tfe_outputs.talos_proxmox.nonsensitive_values["worker_nodes"]
  all_nodes              = merge(local.controller_nodes, local.worker_nodes)
  bootstrap_address_ipv4 = values(local.controller_nodes)[0].address_ipv4
}