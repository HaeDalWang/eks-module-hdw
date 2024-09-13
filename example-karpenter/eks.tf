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

  depends_on = [ module.eks ]
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

  ## SQS
  ## Event bridge

  depends_on = [ module.eks ]
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
  name       = "karpenter-crd"
  repository = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart      = "karpenter-crd"
  version    = "1.0.2"
  namespace  = kubernetes_namespace.karpenter.metadata[0].name

  depends_on = [ resource.aws_eks_addon.coredns ]
} 

# Karpenter 배포
resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart      = "karpenter"
  version    = "1.0.2"
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

  depends_on = [ 
    resource.helm_release.karpenter_crd,
    resource.aws_eks_addon.coredns 
    ]
}

## NodeClass
## 일종의 노드 템플릿과 비슷하다
## 아마존 리눅스 2/ gp3 40Gi/
## securityGroupSelectorTerms.id 부분관련 링크
## https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/sec-group-reqs.html
resource "kubectl_manifest" "karpenter_default_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiSelectorTerms:
      - alias: al2@latest
      role: ${module.karpenter.node_iam_role_name}
      subnetSelectorTerms:
      - tags:
          karpenter.sh/discovery: ${module.eks.cluster_id}
      securityGroupSelectorTerms:
      - id: ${module.eks.cluster_primary_security_group_id}
      blockDeviceMappings:
      - deviceName: /dev/xvda
        ebs:
          volumeSize: 40Gi
          volumeType: gp3
          encrypted: true
      tags:
        ${jsonencode(local.tags)}
    YAML

  depends_on = [
    helm_release.karpenter
  ]
}

## NodePool 
## 일종의 노드그룹과 비슷하다
## x86/ 온디맨드/ c5,m5,r5/ Pool의 CPU 10core/ 만료기간: 720H
resource "kubectl_manifest" "karpenter_default_nodepool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1
    kind: NodePool
    metadata:
      name: default
    spec:
      weight: 50
      template:
        spec:
          requirements:
          - key: kubernetes.io/arch
            operator: In
            values: ["amd64"]
          - key: kubernetes.io/os
            operator: In
            values: ["linux"]
          - key: karpenter.sh/capacity-type
            operator: In
            values: ["on-demand"]
          - key: karpenter.k8s.aws/instance-category
            operator: In
            # values: ["c", "m", "r"]
            values: ["m"]
          - key: karpenter.k8s.aws/instance-generation
            operator: In
            values: ["5"]
          nodeClassRef:
            apiVersion: karpenter.k8s.aws/v1beta1
            kind: EC2NodeClass
            name: "default"
            group: karpenter.k8s.aws
      limits:
        cpu: 1000
      disruption:
        consolidationPolicy: WhenEmptyOrUnderutilized
        consolidateAfter: 720h
  YAML

  depends_on = [
    kubectl_manifest.karpenter_default_node_class
  ]
}

module "eks-addons" {
  source = "../module/eks-addons"

  cluster_name        = module.eks.cluster_id
  cluster_version     = module.eks.cluster_version
  cluster_oidc_issuer = module.eks.cluster_oidc_provider

  enabled_coredns = false
  
  depends_on = [
    kubectl_manifest.karpenter_default_nodepool
  ]
}