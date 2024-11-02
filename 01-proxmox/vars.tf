variable "proxmox_endpoint" {
  type    = string
  default = "https://pve.xmple.io:8006/"
}

variable "proxmox_default_node" {
  type    = string
  default = "pve"
}

variable "proxmox_iso_datastore" {
  type    = string
  default = "local"
}

variable "proxmox_vm_datastore" {
  type    = string
  default = "local-lvm"
}

variable "proxmox_network" {
  type    = string
  default = "vmbr0"
}

variable "proxmox_virtual_machines" {
  type = map(object({
    pve_node      = optional(string)
    cpu_cores     = number
    memory_mb     = number
    disk_gb       = number
    address_ipv4  = optional(string, "dhcp")
    gateway_ipv4  = optional(string)
    labels        = optional(map(string), {})
    is_controller = bool
  }))
}

variable "network_default_gateway_v4" {
  type    = string
  default = "10.1.1.1"
}

variable "network_cidr_v4" {
  type    = string
  default = "10.1.1.0/24"
}

variable "talos_version" {
  type    = string
  default = "v1.8.2"
}
