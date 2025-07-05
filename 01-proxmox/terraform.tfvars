// Comment this line to automatically download the image
proxmox_iso_file = "local:iso/talos-v1.10.5-nocloud-amd64.img"

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
    disk_gb       = 400
  },
  "Talos3" = {
    is_controller = false
    cpu_cores     = 24
    memory_mb     = 16384
    disk_gb       = 400
  },
}
