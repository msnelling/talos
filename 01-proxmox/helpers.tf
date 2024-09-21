locals {
  nodes = {
    for name, node in var.proxmox_virtual_machines : name => {
      name         = name
      node         = lookup(node, "node", var.proxmox_default_node)
      cpu_cores    = node.cpu_cores
      memory_mb    = node.memory_mb
      disk_gb      = node.disk_gb
      address_ipv4 = node.address_ipv4
      gateway_ipv4 = lookup(node, "gateway_ipv4", var.network_default_gateway_v4)
    }
  }

  controller_nodes = [for name, node in var.proxmox_virtual_machines : name if node.is_controller]
  worker_nodes = [for name, node in var.proxmox_virtual_machines : name if !node.is_controller]

  controller_vms = matchkeys(values(proxmox_virtual_environment_vm.node), keys(proxmox_virtual_environment_vm.node), local.controller_nodes)
  worker_vms = matchkeys(values(proxmox_virtual_environment_vm.node), keys(proxmox_virtual_environment_vm.node), local.worker_nodes)
}

locals {
  network_bits_v4 = split("/", var.network_cidr_v4)[1]

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
