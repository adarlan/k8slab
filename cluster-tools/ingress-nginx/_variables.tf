variable "aws_config" {
  type = object({
    foo = string
  })
  default = null
  # TODO validate: kind_config must be null
}

variable "kind_config" {
  type = object({
    foo = string
  })
  default = null
  # TODO validate: aws_config must be null
}
