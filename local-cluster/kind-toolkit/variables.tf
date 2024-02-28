variable "modules" {

  type = object({

    ingress_nginx = object({
      enabled      = bool
      release_name = string
      namespace    = string
    })

    argo_cd = object({
      enabled      = bool
      release_name = string
      namespace    = string
    })

    kube_prometheus_stack = object({
      enabled      = bool
      release_name = string
      namespace    = string
    })

    loki_stack = object({
      enabled      = bool
      release_name = string
      namespace    = string
    })

    trivy_operator = object({
      enabled      = bool
      release_name = string
      namespace    = string
    })
  })
}

variable "port_mappings_by_name" {

  type = map(object({

    host_port = number
    node_port = number
  }))
}
