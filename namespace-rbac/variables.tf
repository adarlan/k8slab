variable "cluster_endpoint" {
  type      = string
  sensitive = true
}

variable "cluster_ca_certificate" {
  type      = string
  sensitive = true
}

variable "namespace_rbac_manager_token" {
  type      = string
  sensitive = true
}
