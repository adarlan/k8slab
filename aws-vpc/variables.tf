
variable "cluster_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "max_az_count" {
  type    = number
  default = 2
  # TODO what is the minimum?
}

variable "max_nat_gateway_count" {
  type    = number
  default = 1
  # TODO what is the minimum?
}
