variable "talos_cluster_name" {
  type    = string
  default = "homelab"
}

variable "talos_controller_vip_ip" {
  type    = string
  default = "10.1.1.40"
}

variable "talos_controller_vip_fqdn" {
  type    = string
  default = "talos-api.xmple.io"
}

variable "talos_schedule_on_controllers" {
  type    = bool
  default = false
}

variable "talos_kube_version" {
  type    = string
  default = "1.32.0"
}

variable "talos_config_file" {
  type    = string
  default = "/Users/mark/.talos/config"
}

variable "kubeconfig_file" {
  type    = string
  default = "/Users/mark/.kube/config"
}

variable "cilium_enabled" {
  type    = bool
  default = true
}

variable "cilium_version" {
  type    = string
  default = "1.17.0"
}

variable "cilium_loadbalancer_ip" {
  type    = string
  default = "10.1.1.49"
}

variable "gateway_api_enabled" {
  type    = bool
  default = false
}

variable "gateway_api_version" {
  type    = string
  default = "1.1.0"
}

variable "argocd_release" {
  type    = string
  default = "2.13"
}