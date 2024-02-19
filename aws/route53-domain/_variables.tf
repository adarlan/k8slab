variable "domain_name" {
  type = string
  description = "Example: example.com"
}

variable "target_address" {
  type = string
  description = "For example a public IP or load balancer URL"
}

variable "privacy" {
  type = bool
  default = true
}
