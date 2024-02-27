variable "worker_node_count" {
  type    = number
  default = 2
}

variable "ingress_nginx" {
  type = object({
    enabled = bool
  })
  default = null
}

variable "argo_cd" {
  type = object({
    enabled = bool
  })
  default = null
}

variable "kube_prometheus_stack" {
  type = object({
    enabled = bool
  })
  default = null
}

variable "loki_stack" {
  type = object({
    enabled = bool
  })
  default = null
}

variable "trivy_operator" {
  type = object({
    enabled = bool
  })
  default = null
}
