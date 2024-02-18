
variable "cluster_name" {
  type = string
}

variable "k8s_auth_credentials" {
  type = object({
    host                   = string
    cluster_ca_certificate = string
    client_certificate     = string
    client_key             = string
  })
  sensitive = true
}

variable "eks_oidc_provider_url" {
  type = string
}

variable "eks_oidc_provider_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "node_group_role_name" {
  type = string
}
