hosts = {
    k8s_cp_01 = {
      name    = "k8s-cp-01"
      cores   = 8
      memory  = 6000
      ip_addr = "10.115.202.53"
      gateway = "10.115.202.1"
      cidr    = "/24"
      node_name = "nlgro-hyppve-p1"
      network_bridge = "vmbr21"
      datastore_id = "local-zfs"
      disk_size = 20
    }
    k8s_worker_01 = {
      name    = "k8s-worker-01"
      cores   = 8
      memory  = 6000
      ip_addr = "10.115.202.54"
      gateway = "10.115.202.1"
      cidr    = "/24"
      node_name = "nlgro-hyppve-p1"
      network_bridge = "vmbr21"
      datastore_id = "local-zfs"
      disk_size = 20
    }
}
proxmox = {
    url                     = "https://10.0.3.10:8006/"
    download_node_name      = "nlgro-hyppve-p1"
    download_datastore_id   = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
    host_description        = "Managed by Terraform"
    host_tags               = ["terraform"]
}

talos = {
    cluster_name             = "test-cluster"
    version                  = "v1.10.6"
    control_plane_identifier = "cp"
    worker_identifier        = "worker"
}



