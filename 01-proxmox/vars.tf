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
    is_controller = bool
    node_name     = optional(string)
    cpu_cores     = number
    memory_mb     = number
    disk_gb       = number
    address_ipv4  = string
    gateway_ipv4  = optional(string)
    labels        = map(string)
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

variable "talos_schematic" {
  type    = string
  default = "88d1f7a5c4f1d3aba7df787c448c1d3d008ed29cfb34af53fa0df4336a56040b"
}

variable "talos_version" {
  type    = string
  default = "v1.7.6"
}
