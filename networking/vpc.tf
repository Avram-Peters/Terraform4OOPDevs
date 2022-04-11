module vpc {
  for_each = var.network_config
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git"

  name="regional-${each.key}"
  cidr = each.value.cidr
  azs = ["${var.region}a", "${var.region}b", "${var.region}c" ]
  private_subnets = each.value.private_subnets
  public_subnets = each.value.public_subnets

  enable_ipv6 = true
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_nat_gateway = false
  single_nat_gateway = true
  public_subnet_tags = {
    "availability": "public"
  }
  private_subnet_tags = {
    "availability": "private"
  }
  tags = var.tags
  vpc_tags = merge({"environment": each.key}, var.vpc_tags)
}





