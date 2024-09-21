locals {
  controller_addresses_ipv4 = data.tfe_outputs.proxmox.nonsensitive_values["controller_addresses_ipv4"]
  worker_addresses_ipv4     = data.tfe_outputs.proxmox.nonsensitive_values["worker_addresses_ipv4"]
}