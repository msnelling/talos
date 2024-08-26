variable "proxmox_endpoint" {
  type    = string
  default = "https://pve.xmple.io:8006/"
}

variable "proxmox_iso_datastore" {
  type    = string
  default = "local"
}

variable "proxmox_vm_datastore" {
  type    = string
  default = "local-lvm"
}

variable "cluster_name" {
  type    = string
  default = "homelab"
}

variable "default_gateway" {
  type    = string
  default = "10.1.1.1"
}

variable "talos_schematic" {
  type    = string
  default = "88d1f7a5c4f1d3aba7df787c448c1d3d008ed29cfb34af53fa0df4336a56040b"
}

variable "talos_version" {
  type    = string
  default = "v1.7.6"
}

variable "talos_cp1_ip_addr" {
  type    = string
  default = "10.1.1.248"
}

variable "talos_worker1_ip_addr" {
  type    = string
  default = "10.1.1.249"
}
