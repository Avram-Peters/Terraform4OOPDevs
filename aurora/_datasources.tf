data aws_subnets secured_subnets {
  filter {
    name = "tag:availability"
    values = ["private"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.deployable_vpc.id]
  }
}

data aws_vpc deployable_vpc {
  filter {
    name   = "tag:Name"
    values = ["regional-${var.environment}"]
  }
}
data aws_region current {}
data aws_caller_identity current {}
data aws_partition current {}

