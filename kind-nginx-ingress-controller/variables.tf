
variable "cluster_credentials" {
    type = object({
        host = string
        cluster_ca_certificate = string
        client_certificate = string
        client_key       = string
    })
}
