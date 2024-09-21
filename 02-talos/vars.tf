variable "talos_cluster_name" {
  type    = string
  default = "homelab"
}

variable "talos_controller_vip" {
  type    = string
  default = "10.1.1.40"
}

variable "talos_schedule_on_controllers" {
  type    = bool
  default = false
}