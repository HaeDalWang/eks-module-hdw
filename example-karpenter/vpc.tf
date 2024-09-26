module "vpc" {
  source = "../module/vpc"

  ## VPC
  name = "${local.name}-${local.environment}"
  cidr = "10.150.0.0/16"

  ## Subnets
  azs             = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  public_subnets  = ["10.150.10.0/24", "10.150.20.0/24", "10.150.30.0/24"]
  private_subnets = ["10.150.110.0/24", "10.150.120.0/24", "10.150.130.0/24"]

  ## NAT Gateway 활성화 유무
  nat_gateway_enabled = true

  ## aws-loadbalancer-controller & karpenter 에 필요한 요구사항 Tag 추가
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                      = 1
  }
  private_subnet_tags = {
    "karpenter.sh/discovery"                      = "${local.cluster_name}"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"             = 1
  }

  tags = local.tags
}