output "controller_nodes" {
  value = terraform_data.controller_nodes.output
}

output "worker_nodes" {
  value = terraform_data.worker_nodes.output
}

output "talos_image_factory_schematic" {
  value = "factory.talos.dev/nocloud-installer/${talos_image_factory_schematic.this.id}:${var.talos_version}"
}