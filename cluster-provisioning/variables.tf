variable "worker_node_count" {
  type = number
}

variable "control_plane_port_mappings" {
  type = list(object({
    host_port = number
    node_port = number
  }))
}

variable "control_plane_node_labels" {
  type = string
}
