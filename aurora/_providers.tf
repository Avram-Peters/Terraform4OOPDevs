terraform {
  backend "s3" {}
  required_version = ">=1.1.4"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.69"
    }
    random = {}
    null = {}
  }
}

provider "random" {}

provider "null" {}

provider "aws"  {
  profile = var.profile
  region=var.region
}

