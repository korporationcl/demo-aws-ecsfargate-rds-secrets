# Networking layer - This uses an already existent module. In the real world, we make our own module.

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "poc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.tags
}
