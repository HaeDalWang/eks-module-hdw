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

  depends_on = [module.vpc]
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

module "eks_common" {
  source = "../module/eks-common"

  cluster_name        = module.eks.cluster_id
  cluster_version     = module.eks.cluster_version
  cluster_oidc_issuer = module.eks.cluster_oidc_provider

  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  metric_server_chart_version                = "3.12.1"
  cluster_autoscaler_chart_version           = "9.37.0"
  external_dns_chart_version                 = "1.14.5"
  aws_load_balancer_controller_chart_version = "1.8.1"
  aws_load_balancer_controller_app_version   = "v2.8.1"
  # nginx_ingress_controller_chart_version     = "4.6.0"

  enable_external_dns = false
  # external_dns_domain_filters = ["seungdobae.com"]
  # external_dns_role_arn       = "arn:aws:iam::032559872243:role/ExternalDNSRole"
  # hostedzone_type             = "private"
  # acm_certificate_arn         = data.terraform_remote_state.common.outputs.mng_ptspro_refinehub_com

  pod_identity_enabled = true
}