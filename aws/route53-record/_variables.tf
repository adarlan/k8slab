variable "domain" {
  type = string
  description = "Example: example.com"
}

variable "subdomain" {
  type = string
  description = "Examples: 'foo' (foo.example.com), '*.foo' (*.foo.example.com)"
}

variable "target_address" {
  type = string
  description = "For example a public IP or load balancer URL"
}
