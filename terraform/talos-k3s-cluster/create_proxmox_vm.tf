resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  content_type            = "iso"
  datastore_id            = "local"
  node_name               = var.node_name
  file_name               = "talos-${var.talos_version}-nocloud-amd64.img"
  url                     = "https://factory.talos.dev/image/aeec243e3a4c2a14f9ba74b1a8c7662f03eea658a7ea5f1c26fdd491280c88f8/${var.talos_version}/nocloud-amd64.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = true
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each    = var.hosts
  name        = each.value.name
  description = "Managed by Terraform"
  tags        = ["terraform"]
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
  }

  disk {
    datastore_id = each.value.datastore_id
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = each.value.disk_size
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = each.value.datastore_id
    ip_config {
      ipv4 {
        address = "${each.value.ip_addr}${var.network_cidr}"
        gateway = var.network_gateway
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }
}
