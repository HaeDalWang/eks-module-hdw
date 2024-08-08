# AWS VPC CNI에 부여할 IAM 정책을 포함하는 ServiceAccount 생성
module "vpc_cni_sa" {
  source = "../eks-irsa"

  name                 = "aws-node"
  cluster_name         = var.cluster_name
  cluster_oidc_issuer  = var.cluster_oidc_issuer
  namespace            = "kube-system"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  create_iam_role_only = true
}

# AWS VPC CNI Add-on 활성화
data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.cluster_version
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = var.cluster_name
  addon_name               = "vpc-cni"
  addon_version            = data.aws_eks_addon_version.vpc_cni.version
  service_account_role_arn = module.vpc_cni_sa.role_arn
  ## 업그레이드 버전값이 충돌날때 해결하는 방법 유형 자세한건 API 문서 확인
  ## https://docs.aws.amazon.com/eks/latest/APIReference/API_UpdateAddon.html#AmazonEKS-UpdateAddon-request-resolveConflicts
  resolve_conflicts_on_update = "OVERWRITE"
}

# CoreDNS Add-on 활성화
data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = var.cluster_version
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
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = var.cluster_name
  addon_name        = "kube-proxy"
  addon_version     = data.aws_eks_addon_version.kube_proxy.version
  ## 업그레이드 버전값이 충돌날때 해결하는 방법 유형 자세한건 API 문서 확인
  ## https://docs.aws.amazon.com/eks/latest/APIReference/API_UpdateAddon.html#AmazonEKS-UpdateAddon-request-resolveConflicts
  resolve_conflicts_on_update = "OVERWRITE"
}

# # AWS EBS CSI Driver에 부여할 IAM 정책을 포함하는 ServiceAccount 생성
# module "ebs_csi_controller_sa" {
#   source = "../eks-irsa"

#   name                 = "ebs-csi-controller-sa"
#   cluster_name         = var.cluster_name
#   cluster_oidc_issuer  = var.cluster_oidc_issuer
#   namespace            = "kube-system"
#   managed_policy_arns  = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
#   create_iam_role_only = true
# }

# # AWS EBS CSI Driver Add-on 활성화
# data "aws_eks_addon_version" "ebs_csi_controller" {
#   addon_name         = "aws-ebs-csi-driver"
#   kubernetes_version = var.cluster_version
# }

# resource "aws_eks_addon" "ebs_csi_controller" {
#   cluster_name             = var.cluster_name
#   addon_name               = "aws-ebs-csi-driver"
#   addon_version            = data.aws_eks_addon_version.ebs_csi_controller.version
#   service_account_role_arn = module.ebs_csi_controller_sa.role_arn
#   resolve_conflicts_on_update = "OVERWRITE"
# }

# # EBS CSI Driver를 사용하는 StorageClass를 생성하고 기본값으로 지정
# resource "kubernetes_storage_class" "ebs_sc" {
#   metadata {
#     name = "ebs-sc"
#     annotations = {
#       "storageclass.kubernetes.io/is-default-class" : "true"
#     }
#   }
#   storage_provisioner = "ebs.csi.aws.com"
#   volume_binding_mode = "WaitForFirstConsumer"

#   depends_on = [
#     aws_eks_addon.ebs_csi_controller
#   ]
# }

# # Reclaim 정책을 Retain으로 하는 StorageClass 생성
# resource "kubernetes_storage_class" "ebs_sc_retain" {
#   metadata {
#     name = "ebs-sc-retain"
#   }
#   storage_provisioner = "ebs.csi.aws.com"
#   reclaim_policy      = "Retain"
#   volume_binding_mode = "WaitForFirstConsumer"

#   depends_on = [
#     aws_eks_addon.ebs_csi_controller
#   ]
# }

# # EKS에서 기본값으로 설정된 StorageClass(gp2)를 해제
# resource "kubernetes_annotations" "default_storageclass" {
#   api_version = "storage.k8s.io/v1"
#   kind        = "StorageClass"
#   force       = "true"

#   metadata {
#     name = "gp2"
#   }
#   annotations = {
#     "storageclass.kubernetes.io/is-default-class" = "false"
#   }

#   depends_on = [
#     kubernetes_storage_class.ebs_sc
#   ]
# }
