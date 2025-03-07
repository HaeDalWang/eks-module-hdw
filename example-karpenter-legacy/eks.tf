module "eks" {
  source = "../module/eks"

  cluster_name    = local.cluster_name
  cluster_version = var.eks_cluster_version

  # 클러스터를 생성할 VPC
  vpc_id = module.vpc.vpc_id
  ## EKS eni가 생성됨 & fargate 가 배포될 서브넷
  # Only Private
  # vpc_subnet_ids = module.vpc.private_subnet_ids
  # Prviate + Public
  vpc_subnet_ids = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)

  ## 클러스터 엔드포인트 Type
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # Fargate 프로필이 사용할 서브넷 오직 프라이빗만 가능하다
  # 사용하지 않으면 기본값은 vpc_subnet_ids을 따라간다
  fargate_subnet_ids = module.vpc.private_subnet_ids
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
  cluster_name                = module.eks.cluster_id
  addon_name                  = "coredns"
  addon_version               = data.aws_eks_addon_version.coredns.version
  resolve_conflicts_on_update = "OVERWRITE"

  // coredns의 request limit은 얼마를 주어야할까  
  // https://github.com/coredns/deployment/blob/master/kubernetes/Scaling_CoreDNS.md
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

  depends_on = [module.eks]
}

## Karpenter 배포 시 필요한 리소스 생성 모듈, SQS, Event Bridge 등 
module "karpenter" {
  source       = "../module/karpenter"
  cluster_name = module.eks.cluster_id

  # 해당 모듈은 기본적으로 무조건 Spot에 대해 사용한다는 가정
  # enabled_spot_linked_role= true

  # Karpenter에 부여할 IAM 역할 생성 
  # 무조건 IRSA을 통해 ServiceAccount 생성
  irsa_oidc_provider_issuer = module.eks.cluster_oidc_provider

  # Karpenter가 생성할 노드에 부여할 역할에 기본 정책 이외에 추가할 IAM 정책
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEBSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    AmazonEFSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  }

  depends_on = [module.eks]
}

# Karpenter를 배포할 네임 스페이스
# namespace 이름 바꿀꺼면 karpenter module에서 Serviceaccount에 대한 변수값을 변경하세요
resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

# Karpenter CRD 배포
resource "helm_release" "karpenter_crd" {
  name                = "karpenter-crd"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter-crd"
  version             = var.karpenter_crd_version
  namespace           = kubernetes_namespace.karpenter.metadata[0].name
  # namespace           = "kube-system"

  depends_on = [resource.aws_eks_addon.coredns]
}

# Karpenter 배포
resource "helm_release" "karpenter" {
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = var.karpenter_version
  namespace           = kubernetes_namespace.karpenter.metadata[0].name

  skip_crds = true

  values = [
    <<-EOT
    settings:
      clusterName: ${module.eks.cluster_id}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
      featureGates:
        spotToSpotConsolidation: true
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter.iam_role_arn}
    EOT
  ]

  timeout = 600

  depends_on = [
    resource.helm_release.karpenter_crd
  ]
}

## vpc-cni, coredns, kube-proxy 설치하는 모듈
module "eks-addons" {
  source = "../module/eks-addons"

  cluster_name        = module.eks.cluster_id
  cluster_version     = module.eks.cluster_version
  cluster_oidc_issuer = module.eks.cluster_oidc_provider

  enabled_coredns = false

  depends_on = [
    kubectl_manifest.karpenter_basic_nodepool
  ]
}

## common echo 프로그램 설치
## ClusterAutoSclaer
## metrics server
## ingress nginx
## external dns
## pod identity agent
module "eks_common" {
  source = "../module/eks-common"

  cluster_name        = module.eks.cluster_id
  cluster_version     = module.eks.cluster_version
  cluster_oidc_issuer = module.eks.cluster_oidc_provider

  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  enabled_cluster_autoscaler = false

  enabled_metric_server       = true
  metric_server_chart_version = var.metrics_server_chart_version

  enabled_external_dns        = true
  external_dns_chart_version  = var.external_dns_chart_version
  external_dns_domain_filters = ["${data.aws_route53_zone.seungdobae.name}"]
  hostedzone_type             = "public"

  pod_identity_enabled = true

  depends_on = [kubectl_manifest.karpenter_basic_nodepool]
}

/* 변수로 설치할 AWS Load Balancer Controller의 버전을 받아서 해당 버전에서
요구되는 IAM 정책 다운로드 */
data "http" "alb_policy_document" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/${var.aws_load_balancer_controller_app_version}/docs/install/iam_policy.json"
  request_headers = {
    Accept = "application/json"
  }
}

# AWS Load Balancer Controller에 부여할 IAM 정책을 포함하는 ServiceAccount 생성
module "aws_load_balancer_controller_service_account" {
  source = "../module/eks-irsa"

  name                = "aws-load-balancer-controller"
  namespace           = "kube-system"
  cluster_oidc_issuer = module.eks.cluster_oidc_provider
  cluster_name        = module.eks.cluster_id
  policy_document     = tostring(data.http.alb_policy_document.response_body)
}

# AWS Load Balancer Controller 설치
module "aws_load_balancer_controller" {
  source = "../module/aws-load-balancer-controller"

  chart_version       = var.aws_load_balancer_controller_chart_version
  app_version         = var.aws_load_balancer_controller_app_version
  cluster_name        = module.eks.cluster_id
  cluster_oidc_issuer = module.eks.cluster_oidc_provider

  service_account_name = module.aws_load_balancer_controller_service_account.serviceaccount_name
  public_subnets       = module.vpc.public_subnet_ids
  private_subnets      = module.vpc.private_subnet_ids

  depends_on = [kubectl_manifest.karpenter_basic_nodepool]
}

# AWS EBS CSI Driver에 부여할 IAM 정책을 포함하는 ServiceAccount 생성
module "ebs_csi_controller_sa" {
  source = "../module/eks-irsa"

  name                 = "ebs-csi-controller-sa"
  cluster_name         = module.eks.cluster_id
  cluster_oidc_issuer  = module.eks.cluster_oidc_provider
  namespace            = "kube-system"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  create_iam_role_only = true
}

# AWS EBS CSI Driver Add-on 활성화
data "aws_eks_addon_version" "ebs_csi_controller" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = module.eks.cluster_version
  most_recent        = false
}

resource "aws_eks_addon" "ebs_csi_controller" {
  cluster_name                = module.eks.cluster_id
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = data.aws_eks_addon_version.ebs_csi_controller.version
  service_account_role_arn    = module.ebs_csi_controller_sa.role_arn
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [kubectl_manifest.karpenter_basic_nodepool]
}

# EBS CSI Driver를 사용하는 StorageClass를 생성하고 기본값으로 지정
resource "kubernetes_storage_class" "ebs_sc" {

  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" : "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  # https://kubernetes.io/ko/docs/concepts/storage/storage-classes/#볼륨-바인딩-모드
  volume_binding_mode = "WaitForFirstConsumer"
  ## 파라미터 보면서 수정 
  ## https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/parameters.md
  parameters = {
    type      = "gp3"
    encrypted = "true"
  }

  depends_on = [
    aws_eks_addon.ebs_csi_controller
  ]
}

# EKS에서 기본값으로 설정된 StorageClass(gp2)를 해제
resource "kubernetes_annotations" "default_storageclass" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = "true"

  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }

  depends_on = [
    kubernetes_storage_class.ebs_sc
  ]
}