hosts = {
    k8s_control_01 = {
      name    = "k8s-control-01"
      cores   = 6
      memory  = 8096
      ip_addr = "10.0.69.60"
      gateway = "10.0.69.1"
      cidr    = "/24"
      node_name = "proxmox"
      network_bridge = "vmbr0"
      vlan_id = 69
      datastore_id = "ssd"
      disk_size = 128
    }
    k8s_control_02 = {
      name    = "k8s-control-02"
      cores   = 6
      memory  = 8096
      ip_addr = "10.0.69.61"
      gateway = "10.0.69.1"
      cidr    = "/24"
      node_name = "proxmox"
      network_bridge = "vmbr0"
      vlan_id = 69
      datastore_id = "ssd"
      disk_size = 128
    }
    k8s_control_03 = {
      name    = "k8s-control-03"
      cores   = 6
      memory  = 8096
      ip_addr = "10.0.69.62"
      gateway = "10.0.69.1"
      cidr    = "/24"
      node_name = "proxmox"
      network_bridge = "vmbr0"
      vlan_id = 69
      datastore_id = "ssd"
      disk_size = 128
    }
}
proxmox = {
    url                     = "https://10.0.3.10:8006/"
    download_node_name      = "proxmox"
    download_datastore_id   = "local"
    host_description        = "Managed by Terraform"
    host_tags               = ["terraform"]
}

talos = {
    cluster_name             = "homelab"
    version                  = "v1.10.6"
    control_plane_identifier = "control"
    worker_identifier        = "worker"
    img_id                   = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
}



