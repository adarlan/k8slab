variable "modules" {

  type = object({

    ingress_nginx = object({
      enabled = bool
    })

    argo_cd = object({
      enabled = bool
    })

    kube_prometheus_stack = object({
      enabled = bool
    })

    loki_stack = object({
      enabled = bool
    })

    trivy_operator = object({
      enabled = bool
    })
  })
}

variable "port_mappings_by_name" {

  type = map(object({

    host_port = number
    node_port = number
  }))
}
