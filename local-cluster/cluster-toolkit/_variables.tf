variable "ingress_nginx" {
  type    = object({})
  default = null
}

variable "argo_cd" {

  type = object({})

  default = null

  # validation {
  #   condition     = var.argo_cd == null || can(regex("8[0-9]{3}", var.argo_cd.http_port_on_host)) && can(regex("8[0-9]{3}", var.argo_cd.https_port_on_host))
  #   error_message = "Ports on host must have four digits and start with '8'."
  # }
}

variable "kube_prometheus_stack" {

  type = object({})

  default = null

  # validation {
  #   condition     = var.kube_prometheus_stack == null || can(regex("8[0-9]{3}", var.kube_prometheus_stack.prometheus_port_on_host)) && can(regex("8[0-9]{3}", var.kube_prometheus_stack.grafana_port_on_host))
  #   error_message = "Ports on host must have four digits and start with '8'."
  # }
}

variable "trivy_operator" {
  type    = object({})
  default = null
}

variable "port_mappings" {
  type = list(object({
    name = string
    node_port = string
    host_port = string
  }))
}
