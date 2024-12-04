data "aws_region" "current" {}

# Metric Server 설치
resource "helm_release" "metric_server" {
  count      = var.enabled_metric_server ? 1 : 0
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = var.metric_server_chart_version
  namespace  = "kube-system"
  timeout    = 900
}

# Cluster Autoscaler에 사용할 IRSA 생성
module "cluster_autoscaler_sa" {
  count  = var.enabled_cluster_autoscaler ? 1 : 0
  source = "../eks-irsa"

  name                = "cluster-autoscaler"
  namespace           = "kube-system"
  cluster_name        = var.cluster_name
  cluster_oidc_issuer = var.cluster_oidc_issuer

  policy_document = <<EOF
{
  "Version": "2012-10-17",
  "Statement" : [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeInstanceTypes"
      ]
    }
  ]
}
EOF
}

# Cluster Autoscaler 설치
resource "helm_release" "cluster_autoscaler" {
  count      = var.enabled_cluster_autoscaler ? 1 : 0
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = var.cluster_autoscaler_chart_version
  namespace  = "kube-system"
  timeout    = 900

  dynamic "set" {
    for_each = {
      "fullnameOverride"           = "cluster-autoscaler"
      "awsRegion"                  = data.aws_region.current.name
      "autoDiscovery.clusterName"  = var.cluster_name
      "rbac.serviceAccount.create" = false
      "rbac.serviceAccount.name"   = module.cluster_autoscaler_sa[0].serviceaccount_name
      "service.create"             = false
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}

# ExternalDNS에서 사용할 IRSA 생성
module "external_dns_sa" {
  count  = var.enabled_external_dns ? 1 : 0
  source = "../eks-irsa"

  name                = "external-dns"
  namespace           = "kube-system"
  cluster_name        = var.cluster_name
  cluster_oidc_issuer = var.cluster_oidc_issuer

  ## 최소권한의 규칙을 챙기기 위해서는 호스트존을 변수에 따라 변경하도록 조정해야함
  policy_document = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:ListTagsForResource"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

# External DNS 설치
resource "helm_release" "external_dns" {
  count = var.enabled_external_dns ? 1 : 0

  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  version    = var.external_dns_chart_version
  namespace  = "kube-system"
  timeout    = 900

  dynamic "set" {
    for_each = {
      "serviceAccount.create" = false
      "serviceAccount.name"   = module.external_dns_sa[0].serviceaccount_name
      "txtOwnerId"    = var.cluster_name
      "domainFilters" = "{${join(",", var.external_dns_domain_filters)}}"
      "policy" = "sync"
      "extraArgs"     = "{--aws-zone-type=${var.hostedzone_type}}"
    }
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [module.external_dns_sa]
}

# Pod identity agent 
data "aws_eks_addon_version" "pod-identity-agent" {
  addon_name         = "eks-pod-identity-agent"
  kubernetes_version = var.cluster_version
}

resource "aws_eks_addon" "pod-identity-agent" {
  count = var.pod_identity_enabled ? 1 : 0

  cluster_name  = var.cluster_name
  addon_name    = "eks-pod-identity-agent"
  addon_version = data.aws_eks_addon_version.pod-identity-agent.version
  ## 업그레이드 버전값이 충돌날때 해결하는 방법 유형 자세한건 API 문서 확인
  ## https://docs.aws.amazon.com/eks/latest/APIReference/API_UpdateAddon.html#AmazonEKS-UpdateAddon-request-resolveConflicts
  resolve_conflicts_on_update = "OVERWRITE"
}

# # NGINX Ingress Controller 설치
# resource "helm_release" "nginx_ingress_controller" {
#   count = var.enabled_nginx_ingress_controller ? 1 : 0
#   name       = "ingress-nginx"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   version    = var.nginx_ingress_controller_chart_version
#   namespace  = "kube-system"
#   timeout    = 900

#   values = [
#     "${file("./helm_values/ingress-nginx_values.yaml")}"
#   ]

#   dynamic "set" {
#     for_each = {
#       "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert" : var.acm_certificate_arn
#     }
#     content {
#       name  = set.key
#       value = set.value
#     }
#   }
#   depends_on = [
#     module.aws_load_balancer_controller.status
#   ]
# }