variable "kubernetes_version" {
  type    = string
  default = "1.29.1"
}

variable "cluster_name" {
  type = string
}

variable "port_mappings" {
  type = list(object({
    name = string
    node_port = string
    host_port = string
  }))
}

variable "worker_nodes" {
  type = number
}

variable "controll_plane_node_labels" {
  type = list(string)
}
