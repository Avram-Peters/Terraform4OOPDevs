variable network_config {
  type = map(object({
    cidr = string
    private_subnets = list(string)
    public_subnets = list(string)
  }))
}

variable tags {
  type = map(string)
}
variable vpc_tags {
  type = map(string)
}

variable region {
  type = string
}