hosts = {
    talos_cp_01 = {
      name    = "talos-cp-01"
      cores   = 2
      memory  = 4096
      ip_addr = "10.0.3.240"
      gateway = "10.0.3.1"
      cidr    = "/24"
      node_name = "proxmox"
      network_bridge = "vmbr0"
      datastore_id = "ssd"
      disk_size = 20
    }
    talos_cp_02 = {
      name    = "talos-cp-02"
      cores   = 2
      memory  = 4096
      ip_addr = "10.0.3.239"
      gateway = "10.0.3.1"
      cidr    = "/24"
      node_name = "proxmox"
      network_bridge = "vmbr0"
      datastore_id = "ssd"
      disk_size = 20
    }
    talos_worker_01 = {
      name    = "talos-worker-01"
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
    talos_worker_02 = {
      name    = "talos-worker-02"
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
}

node_name = "proxmox"