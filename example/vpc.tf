module "vpc" {
  source  = "../module/vpc"

  name = "test"
  cidr= ""

  prefix     = local.env
  suffix     = "sb-public"
  vpc_id     = module.vpc.vpc_id
  azs        = data.aws_availability_zones.azs.names
  cidr       = ["10.131.1.0/24", "10.131.2.0/24", "10.131.3.0/24"]
  type       = "public"
  gateway_id = module.vpc.igw_id


  # public_subnet_tags = {
  #   "kubernetes.io/cluster/${local.name}" = "shared"
  #   "kubernetes.io/role/elb"              = 1
  # }
  # private_subnet_tags = {
  #   "kubernetes.io/cluster/${local.name}" = "shared"
  #   "kubernetes.io/role/internal-elb"     = 1
  # }

  tags = local.tags
}