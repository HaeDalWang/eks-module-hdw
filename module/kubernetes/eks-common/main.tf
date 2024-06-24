data "aws_region" "current" {}

# Metric Server 설치
resource "helm_release" "metric_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = var.metric_server_chart_version
  namespace  = "kube-system"
  timeout    = 900
}

# Cluster Autoscaler에 사용할 IRSA 생성
module "cluster_autoscaler_sa" {
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
      "rbac.serviceAccount.name"   = module.cluster_autoscaler_sa.serviceaccount_name
      "service.create"             = false
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}

# External DNS 설치
resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  version    = var.external_dns_chart_version
  namespace  = "kube-system"
  timeout    = 900

  dynamic "set" {
    for_each = {
      "serviceAccount.create"                                     = true
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = var.external_dns_role_arn
      "txtOwnerId"                                                = var.cluster_name
      "domainFilters"                                             = "{${join(",", var.external_dns_domain_filters)}}"
      "extraArgs"                                                 = "{--aws-zone-type=${var.hostedzone_type}}"
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}

# AWS Load Balancer Controller 설치
module "aws_load_balancer_controller" {
  source = "../aws-load-balancer-controller"

  chart_version       = var.aws_load_balancer_controller_chart_version
  app_version         = var.aws_load_balancer_controller_app_version
  cluster_name        = var.cluster_name
  cluster_oidc_issuer = var.cluster_oidc_issuer

  public_subnets  = var.public_subnet_ids
  private_subnets = var.private_subnet_ids
}

# NGINX Ingress Controller 설치
resource "helm_release" "nginx_ingress_controller" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.nginx_ingress_controller_chart_version
  namespace  = "kube-system"
  timeout    = 900

  values = [
    "${file("./helm_values/ingress-nginx_values.yaml")}"
  ]

  dynamic "set" {
    for_each = {
      "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert" : var.acm_certificate_arn
    }
    content {
      name  = set.key
      value = set.value
    }
  }
  depends_on = [
    module.aws_load_balancer_controller.status
  ]
}