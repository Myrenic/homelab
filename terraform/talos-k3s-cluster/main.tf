terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.60.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.5.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox.url
  insecure = true # Only needed if your Proxmox server is using a self-signed certificate
}