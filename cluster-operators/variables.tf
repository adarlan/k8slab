variable "cluster_endpoint" {
  type      = string
  sensitive = true
}

variable "cluster_ca_certificate" {
  type      = string
  sensitive = true
}

variable "root_user_certificate" {
  type      = string
  sensitive = true
}

variable "root_user_key" {
  type      = string
  sensitive = true
}
