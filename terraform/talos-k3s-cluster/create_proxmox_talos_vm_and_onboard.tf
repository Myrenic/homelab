locals {
  control_plane_ips = [
    for host_key, host in var.hosts :
    host.ip_addr if strcontains(host.name, "${var.talos.control_plane_identifier}")
  ]

  worker_ips = [
    for host_key, host in var.hosts :
    host.ip_addr if strcontains(host.name, "${var.talos.worker_identifier}")
  ]
}

resource "talos_machine_secrets" "machine_secrets" {}

resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type            = "iso"
  datastore_id            = var.proxmox.download_datastore_id
  node_name               = var.proxmox.download_node_name
  file_name               = "talos-${var.talos.version}-nocloud-amd64.img"
  url                     = "https://factory.talos.dev/image/${var.talos.img_id}/${var.talos.version}/nocloud-amd64.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = false
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each    = var.hosts
  name        = each.value.name
  description = var.proxmox.host_description
  tags        = var.proxmox.host_tags
  node_name   = each.value.node_name
  on_boot     = true

  cpu {
    cores = each.value.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = each.value.memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = each.value.network_bridge
    vlan_id = each.value.vlan_id
  }

  disk {
    datastore_id = each.value.datastore_id
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = each.value.disk_size
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = each.value.datastore_id
    ip_config {
      ipv4 {
        address = "${each.value.ip_addr}${each.value.cidr}"
        gateway = each.value.gateway
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }
}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.talos.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = local.control_plane_ips
}

data "talos_machine_configuration" "machineconfig_cp" {
  for_each         = { for ip in local.control_plane_ips : ip => ip }
  cluster_name     = var.talos.cluster_name
  cluster_endpoint = "https://${each.key}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

resource "talos_machine_configuration_apply" "cp_config_apply" {
  for_each                    = { for ip in local.control_plane_ips : ip => ip }
  depends_on                  = [proxmox_virtual_environment_vm.vm]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp[each.key].machine_configuration
  node                        = each.key
}

data "talos_machine_configuration" "machineconfig_worker" {
  for_each         = { for ip in local.worker_ips : ip => ip }
  cluster_name     = var.talos.cluster_name
  cluster_endpoint = "https://${local.control_plane_ips[0]}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

resource "talos_machine_configuration_apply" "worker_config_apply" {
  for_each                    = { for ip in local.worker_ips : ip => ip }
  depends_on                  = [proxmox_virtual_environment_vm.vm]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker[each.key].machine_configuration
  node                        = each.key
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [talos_machine_configuration_apply.cp_config_apply]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.control_plane_ips[0]
}

data "talos_cluster_health" "health" {
  depends_on           = [talos_machine_bootstrap.bootstrap,talos_machine_configuration_apply.cp_config_apply, talos_machine_configuration_apply.worker_config_apply]
  client_configuration = data.talos_client_configuration.talosconfig.client_configuration
  control_plane_nodes  = local.control_plane_ips
  worker_nodes         = local.worker_ips
  endpoints            = data.talos_client_configuration.talosconfig.endpoints
}

data "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.control_plane_ips[0]
}

output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}