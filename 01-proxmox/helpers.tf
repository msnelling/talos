locals {
  controller_nodes = [for name, node in var.proxmox_virtual_machines : name if node.is_controller]
  worker_nodes     = [for name, node in var.proxmox_virtual_machines : name if !node.is_controller]

  controller_vms = matchkeys(values(proxmox_virtual_environment_vm.node), keys(proxmox_virtual_environment_vm.node), local.controller_nodes)
  worker_vms     = matchkeys(values(proxmox_virtual_environment_vm.node), keys(proxmox_virtual_environment_vm.node), local.worker_nodes)
}

locals {
  controller_addresses_ipv4 = flatten(
    [for vm in local.controller_vms :
      [for ip in flatten(vm.ipv4_addresses) : ip if ip != "127.0.0.1"]
    ]
  )

  worker_addresses_ipv4 = flatten(
    [for vm in local.worker_vms :
      [for ip in flatten(vm.ipv4_addresses) : ip if ip != "127.0.0.1"]
    ]
  )
}

resource "terraform_data" "controller_nodes" {
  input = {
    for vm in local.controller_vms : vm.name => {
      address_ipv4 = [for ip in flatten(vm.ipv4_addresses) : ip if provider::netparse::contains_ip(var.network_cidr_v4, ip)][0]
    }
  }

  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_vm.node]
  }
}

resource "terraform_data" "worker_nodes" {
  input = {
    for vm in local.worker_vms : vm.name => {
      address_ipv4 = [for ip in flatten(vm.ipv4_addresses) : ip if provider::netparse::contains_ip(var.network_cidr_v4, ip)][0]
    }
  }

  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_vm.node]
  }
}