# AWS VPC CNI에 부여할 IAM 정책을 포함하는 ServiceAccount 생성
# 권한분리 빡세게 하고 싶으면 노드 Role에서 제외하고 여기서 추가
# module "vpc_cni_sa" {
#   source = "../eks-irsa"

#   name                 = "aws-node"
#   cluster_name         = var.cluster_name
#   cluster_oidc_issuer  = var.cluster_oidc_issuer
#   namespace            = "kube-system"
#   managed_policy_arns  = ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
#   create_iam_role_only = true
# }

# AWS VPC CNI Add-on 활성화
data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.cluster_version
  most_recent = var.most_recent
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = var.cluster_name
  addon_name               = "vpc-cni"
  addon_version            = data.aws_eks_addon_version.vpc_cni.version

  # service_account_role_arn = module.vpc_cni_sa.role_arn
  ## 업그레이드 버전값이 충돌날때 해결하는 방법 유형 자세한건 API 문서 확인
  ## https://docs.aws.amazon.com/eks/latest/APIReference/API_UpdateAddon.html#AmazonEKS-UpdateAddon-request-resolveConflicts
  resolve_conflicts_on_update = "OVERWRITE"
}

# CoreDNS Add-on 활성화
data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = var.cluster_version
    most_recent = var.most_recent
}

resource "aws_eks_addon" "coredns" {
  count  = var.enabled_coredns ? 1 : 0
  cluster_name      = var.cluster_name
  addon_name        = "coredns"
  addon_version     = data.aws_eks_addon_version.coredns.version
  ## 업그레이드 버전값이 충돌날때 해결하는 방법 유형 자세한건 API 문서 확인
  ## https://docs.aws.amazon.com/eks/latest/APIReference/API_UpdateAddon.html#AmazonEKS-UpdateAddon-request-resolveConflicts
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode(var.coredns_configuration_values)
}

# Kube-proxy
data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = var.cluster_version
    most_recent = var.most_recent
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = var.cluster_name
  addon_name        = "kube-proxy"
  addon_version     = data.aws_eks_addon_version.kube_proxy.version
  ## 업그레이드 버전값이 충돌날때 해결하는 방법 유형 자세한건 API 문서 확인
  ## https://docs.aws.amazon.com/eks/latest/APIReference/API_UpdateAddon.html#AmazonEKS-UpdateAddon-request-resolveConflicts
  resolve_conflicts_on_update = "OVERWRITE"
}