proxmox_virtual_machines = {
  "Talos1" = {
    is_controller = true
    cpu_cores     = 4
    memory_mb     = 4096
    disk_gb       = 20
  },
  "Talos2" = {
    is_controller = false
    cpu_cores     = 24
    memory_mb     = 16384
    disk_gb       = 200
  },
  "Talos3" = {
    is_controller = false
    cpu_cores     = 24
    memory_mb     = 16384
    disk_gb       = 200
  },
}
