

locals {
  control_plane_ips = [
    for host_key, host in var.hosts :
    host.ip_addr if strcontains(host.name, "cp")
  ]

  worker_ips = [
    for host_key, host in var.hosts :
    host.ip_addr if strcontains(host.name, "worker")
  ]
}
output "control_plane_ips" {
  value = local.control_plane_ips
}

output "worker_ips" {
  value = local.worker_ips
}

resource "talos_machine_secrets" "machine_secrets" {}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = local.control_plane_ips
}

data "talos_machine_configuration" "machineconfig_cp" {
  for_each         = { for ip in local.control_plane_ips : ip => ip }
  cluster_name     = var.cluster_name
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
  cluster_name     = var.cluster_name
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
  depends_on           = [talos_machine_configuration_apply.cp_config_apply, talos_machine_configuration_apply.worker_config_apply]
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
