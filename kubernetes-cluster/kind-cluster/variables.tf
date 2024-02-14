variable "kubernetes_version" {
  type    = string
  default = "1.29.1"
}

variable "cluster_name" {
  type = string
}

variable "node_to_host_port_mapping" {
  type = map(string)
}
