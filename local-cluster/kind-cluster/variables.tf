variable "worker_node_count" {
  type = number
}

variable "port_mappings" {
  type = list(object({
    host_port = number
    node_port = number
  }))
}

variable "controll_plane_node_labels" {
  type = string
}
