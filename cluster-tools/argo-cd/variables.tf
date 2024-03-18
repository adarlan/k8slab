variable "cluster_tools_installer_token" {
  type      = string
  sensitive = true
}

variable "cluster_ca_certificate" {
  type      = string
  sensitive = true
}

variable "cluster_endpoint" {
  type      = string
  sensitive = true
}
