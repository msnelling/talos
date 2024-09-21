proxmox_virtual_machines = {
  "Talos1" = {
    is_controller = true
    cpu_cores     = 2
    memory_mb     = 3072
    disk_gb       = 20
    address_ipv4  = "10.1.1.41/24"
    labels        = {}
  },
  "Talos2" = {
    is_controller = false
    cpu_cores     = 24
    memory_mb     = 16384
    disk_gb       = 200
    address_ipv4  = "10.1.1.42"
    labels        = {}
  },
  "Talos3" = {
    is_controller = false
    cpu_cores     = 24
    memory_mb     = 16384
    disk_gb       = 200
    address_ipv4  = "10.1.1.43"
    labels        = {}
  },
}
