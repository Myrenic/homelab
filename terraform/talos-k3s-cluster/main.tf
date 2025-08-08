terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
    talos = {
      source = "siderolabs/talos"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox.url
  insecure = true # Only needed if your Proxmox server is using a self-signed certificate
}