hosts = {
    k8s_control_01 = {
      name    = "k8s-control-01"
      cores   = 6
      memory  = 8096
      ip_addr = "10.0.3.240"
      gateway = "10.0.3.1"
      cidr    = "/24"
      node_name = "proxmox"
      network_bridge = "vmbr0"
      datastore_id = "ssd"
      disk_size = 20
    }
    k8s_control_02 = {
      name    = "k8s-control-02"
      cores   = 6
      memory  = 8096
      ip_addr = "10.0.3.239"
      gateway = "10.0.3.1"
      cidr    = "/24"
      node_name = "proxmox"
      network_bridge = "vmbr0"
      datastore_id = "ssd"
      disk_size = 20
    }
    k8s_worker_01 = {
      name    = "k8s-worker-01"
      cores   = 4
      memory  = 4096
      ip_addr = "10.0.3.241"
      gateway = "10.0.3.1"
      cidr    = "/24"
      node_name = "proxmox"
      network_bridge = "vmbr0"
      datastore_id = "ssd"
      disk_size = 20
    }
    k8s_worker_02 = {
      name    = "k8s-worker-02"
      cores   = 4
      memory  = 4096
      ip_addr = "10.0.3.242"
      gateway = "10.0.3.1"
      cidr    = "/24"
      node_name = "proxmox"
      network_bridge = "vmbr0"
      datastore_id = "ssd"
      disk_size = 20
    }
    k8s_worker_03 = {
      name    = "k8s-worker-03"
      cores   = 2
      memory  = 2048
      ip_addr = "10.0.3.243"
      gateway = "10.0.3.1"
      cidr    = "/24"
      node_name = "proxmox"
      network_bridge = "vmbr0"
      datastore_id = "ssd"
      disk_size = 20
    }
    k8s_worker_04 = {
      name    = "k8s-worker-04"
      cores   = 2
      memory  = 2048
      ip_addr = "10.0.3.244"
      gateway = "10.0.3.1"
      cidr    = "/24"
      node_name = "proxmox"
      network_bridge = "vmbr0"
      datastore_id = "ssd"
      disk_size = 20
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
    cluster_name             = "test-cluster"
    version                  = "v1.10.6"
    control_plane_identifier = "control"
    worker_identifier        = "worker"
    img_id                   = "aeec243e3a4c2a14f9ba74b1a8c7662f03eea658a7ea5f1c26fdd491280c88f8"
}



