module "eks" {
  source = "../module/eks"

  cluster_name    = local.cluster_name
  cluster_version = "1.29"

  # 클러스터를 생성할 VPC
  vpc_id = module.vpc.vpc_id
  ## EKS eni가 생성될 서브넷
  vpc_subnet_ids = module.vpc.private_subnet_ids

  ## 클러스터 엔드포인트 Type
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  tags = local.tags
}

module "nodegroup" {
  source = "../module/eks-ng"

  name            = "sandbox"
  cluster_name    = module.eks.cluster_id
  cluster_version = module.eks.cluster_version
  subnet_ids      = module.vpc.private_subnet_ids

  instance_types = ["t3.medium"]
  min_size       = 2
  max_size       = 5

  user_data = ""

  tags = local.tags
}

module "eks-addons" {
  source = "../module/eks-addons"

  cluster_name        = module.eks.cluster_id
  cluster_version     = module.eks.cluster_version
  cluster_oidc_issuer = module.eks.cluster_oidc_provider

  depends_on = [ 
    module.nodegroup 
    ]
}