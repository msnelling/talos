provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = "${local.vault_secret_proxmox_username}!${local.vault_secret_proxmox_token_name}=${local.vault_secret_proxmox_token}"

  ssh {
    agent    = true
    username = "root"
  }
}

resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type            = "iso"
  datastore_id            = var.proxmox_iso_datastore
  node_name               = "pve"
  file_name               = "talos-${var.talos_version}-nocloud-amd64-secureboot.img"
  url                     = "https://factory.talos.dev/image/${var.talos_schematic}/${var.talos_version}/nocloud-amd64-secureboot.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = false
}

resource "proxmox_virtual_environment_vm" "talos_cp1" {
  name        = "talos-cp1"
  description = "Managed by Terraform"
  tags        = ["terraform", "talos"]
  node_name   = "pve"
  on_boot     = true
  bios        = "ovmf"

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = var.proxmox_vm_datastore
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 20
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  tpm_state {
    version = "v2.0"
  }

  initialization {
    datastore_id = var.proxmox_vm_datastore
    ip_config {
      ipv4 {
        address = "${var.talos_cp1_ip_addr}/24"
        gateway = var.default_gateway
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "talos_worker1" {
  depends_on  = [proxmox_virtual_environment_vm.talos_cp1]
  name        = "talos-worker1"
  description = "Managed by Terraform"
  tags        = ["terraform", "talos"]
  node_name   = "pve"
  on_boot     = true
  bios        = "ovmf"

  cpu {
    cores = 4
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = var.proxmox_vm_datastore
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 20
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  tpm_state {
    version = "v2.0"
  }

  initialization {
    datastore_id = var.proxmox_vm_datastore
    ip_config {
      ipv4 {
        address = "${var.talos_worker1_ip_addr}/24"
        gateway = var.default_gateway
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }
}
