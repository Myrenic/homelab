variable "hosts" {
  description = "List of hosts with their properties"
  type = map(object({
    name        = string
    cores       = number
    memory      = number
    ip_addr     = string
    gateway     = string
    cidr        = string
    node_name   = string
    network_bridge = string
    datastore_id = string
    disk_size = number
  }))
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "node_name" {
  description = "Proxmox Node Name"
  type        = string
}

variable "talos_version" {
  description = "talos version"
  type        = string
}

variable "network_cidr" {
  description = "Network CIDR"
  type        = string
  default     = "/24"
}

variable "network_gateway" {
  description = "Network Gateway"
  type        = string
  default     = "10.0.3.1"
}