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

variable "talos_kube_version" {
  type    = string
  default = "1.31.0"
}

variable "cilium_version" {
  type    = string
  default = "1.16.1"
}

variable "cilium_loadbalancer_ip" {
  type    = string
  default = "10.1.1.49"
}

variable "gateway_api_version" {
  type    = string
  default = "1.1.0"
}

variable "argocd_chart_version" {
  type    = string
  default = "7.6.1"
}