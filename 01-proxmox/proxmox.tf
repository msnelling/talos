resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type            = "iso"
  datastore_id            = var.proxmox_iso_datastore
  node_name               = "pve"
  file_name               = "talos-${var.talos_version}-nocloud-amd64.img"
  url                     = "https://factory.talos.dev/image/${talos_image_factory_schematic.this.id}/${var.talos_version}/nocloud-amd64.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = false
}

resource "proxmox_virtual_environment_vm" "node" {
  for_each = local.nodes

  name            = each.value.name
  description     = "Managed by Terraform"
  node_name       = each.value.node
  on_boot         = true
  stop_on_destroy = true
  bios            = "ovmf"
  machine         = "q35"
  tags            = sort(["terraform", "talos"])

  cpu {
    cores = each.value.cpu_cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = each.value.memory_mb
  }

  vga {
    type = "qxl"
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = var.proxmox_network
  }

  efi_disk {
    datastore_id = var.proxmox_vm_datastore
    type         = "4m"
  }

  tpm_state {
    version = "v2.0"
  }

  disk {
    datastore_id = var.proxmox_vm_datastore
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = each.value.disk_gb
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = var.proxmox_vm_datastore
    ip_config {
      ipv4 {
        /*
        address = each.value.address_cidrv4
        gateway = each.value.gateway_ipv4
        */
        address = "dhcp"
      }
    }
  }
}
