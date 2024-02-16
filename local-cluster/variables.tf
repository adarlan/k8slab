variable "cluster_name" {
  type = string
  default = "k8slab"
}

variable "port_suffixes" {
  description = "Defines the port suffixes for various cluster services as 3-digit strings. When accessed within the cluster, these services will use '30' as the prefix for node ports, while outside the cluster, they will use '8' as the prefix."

  type = object({
    argocd_http  = string
    argocd_https = string
    prometheus   = string
    grafana      = string
  })

  default = {
    argocd_http  = "020"
    argocd_https = "021"
    prometheus   = "030"
    grafana      = "031"
  }

  validation {
    condition = alltrue([
      for key, value in var.port_suffixes : can(regex("^[0-9]{3}$", value))
    ])
    error_message = "Port suffixes must be three digits long and consist only of numbers (0-9)."
  }
}
