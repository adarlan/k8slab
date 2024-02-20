variable "domain_name" {
  type = string
  description = "Example: example.com"
}

variable "target_address" {
  type = string
  description = "For example a public IP or load balancer URL"
}

variable "registered_domain" {
  type = object({
    set_privacy  = bool
  })
  description = "Set this only if the domain is registered in your account's Route53"
}

variable "subdomains" {
  type = list(object({
    subdomain_name = string
    target_address = string
  }))
  description = "subdomain_name examples: '*' (*.example.com), 'foo' (foo.example.com), '*.foo' (*.foo.example.com); target_address can be for example a public IP or load balancer URL"
}
