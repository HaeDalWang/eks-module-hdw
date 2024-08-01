module "eks" {
  source = "../module/eks"

  cluster_name    = local.cluster_name
  cluster_version = "1.30"

  # 클러스터를 생성할 VPC
  vpc_id = module.vpc.vpc_id
  ## EKS eni가 생성됨 & fargate 가 배포될 서브넷
  vpc_subnet_ids = module.vpc.private_subnet_ids

  ## 클러스터 엔드포인트 Type
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  ## Fargate Profile
  fargate_profiles = {
    # Karpenter를 Fargate에 실행
    karpenter = {
      selectors = [
        {
          namespace = "karpenter"
        }
      ]
    }
    # CoreDNS를 Fargate에 실행
    coredns = {
      selectors = [
        {
          namespace = "kube-system"
          labels = {
            "k8s-app" = "kube-dns"         
            }
        }
      ]
    }
  }

  tags = local.tags

  depends_on = [module.vpc]
}

## karpenter 배포전 모든 addons 설치 시 서로가 의존관계가 되는 부분을 위해 coredns만 별도로 먼저 설치
# CoreDNS Add-on 활성화
data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = module.eks.cluster_version
}
resource "aws_eks_addon" "coredns" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "coredns"
  addon_version     = data.aws_eks_addon_version.coredns.version
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    computeType = "Fargate"
    resources = {
      limits = {
        cpu    = "0.25"
        memory = "256M"
      }
      requests = {
        cpu    = "0.25"
        memory = "256M"
      }
    }
  })
}

## Karpenter 배포 시 필요한 리소스 생성 모듈
module "karpenter" {
  source  = "../module/karpenter"
  cluster_name = module.eks.cluster_id

  # 해당 모듈은 기본적으로 무조건 Spot에 대해 사용한다는 가정
  enabled_spot_linked_role= true

  # Karpenter에 부여할 IAM 역할 생성 
  # 무조건 IRSA을 통해 ServiceAccount 생성
  irsa_oidc_provider_issuer = module.eks.cluster_oidc_provider

  # Karpenter가 생성할 노드에 부여할 역할에 기본 정책 이외에 추가할 IAM 정책
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEBSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    AmazonEFSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  }
}

# Karpenter를 배포할 네임 스페이스
# namespace 이름 바꿀꺼면 karpenter module에서 Serviceaccount에 대한 변수값을 변경하세요
resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

# Karpenter 배포
resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart      = "karpenter"
  version    = "0.37.0"
  namespace  = kubernetes_namespace.karpenter.metadata[0].name

  values = [
    <<-EOT
    settings:
      clusterName: ${module.eks.cluster_id}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: 
      featureGates:
        spotToSpotConsolidation: true
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter.iam_role_arn}
    EOT
  ]
}

## NodeClass

## NodePool


# module er"eks-addons" {
#   source = "../module/eks-addons"

#   cluster_name        = module.eks.cluster_id
#   cluster_version     = module.eks.cluster_version
#   cluster_oidc_issuer = module.eks.cluster_oidc_provider

#   enabled_coredns = false
  
#   depends_on = [
#     module.eks
#   ]
# }

# module "eks_common" {
#   source = "../module/eks-common"

#   cluster_name        = module.eks.cluster_id
#   cluster_version     = module.eks.cluster_version
#   cluster_oidc_issuer = module.eks.cluster_oidc_provider

#   public_subnet_ids  = module.vpc.public_subnet_ids
#   private_subnet_ids = module.vpc.private_subnet_ids

#   metric_server_chart_version                = "3.12.1"
#   cluster_autoscaler_chart_version           = "9.37.0"
#   external_dns_chart_version                 = "1.14.5"
#   aws_load_balancer_controller_chart_version = "1.8.1"
#   aws_load_balancer_controller_app_version   = "v2.8.1"
#   # nginx_ingress_controller_chart_version     = "4.6.0"

#   enable_external_dns = false
#   # external_dns_domain_filters = ["seungdobae.com"]
#   # external_dns_role_arn       = "arn:aws:iam::032559872243:role/ExternalDNSRole"
#   # hostedzone_type             = "private"
#   # acm_certificate_arn         = data.terraform_remote_state.common.outputs.mng_ptspro_refinehub_com

#   pod_identity_enabled = true
# }