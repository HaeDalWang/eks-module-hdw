locals {
  name = "aws-load-balancer-controller"
}

/* 변수로 설치할 AWS Load Balancer Controller의 버전을 받아서 해당 버전에서
요구되는 IAM 정책 다운로드 */
data "http" "policy_document" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/${var.app_version}/docs/install/iam_policy.json"
  request_headers = {
    Accept = "application/json"
  }
}

# AWS Load Balancer Controller에 부여할 IAM 정책을 포함하는 ServiceAccount 생성
module "service_account" {
  source = "../eks-irsa"

  name                = local.name
  namespace           = "kube-system"
  cluster_oidc_issuer = var.cluster_oidc_issuer
  cluster_name        = var.cluster_name
  policy_document     = tostring(data.http.policy_document.response_body)
}

# AWS Load Balancer Controller 헬름 차트
resource "helm_release" "this" {
  name       = local.name
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.chart_version
  namespace  = "kube-system"
  timeout    = 900

  dynamic "set" {
    for_each = {
      "clusterName"           = var.cluster_name
      "serviceAccount.create" = false
      "serviceAccount.name"   = module.service_account.serviceaccount_name
      "replicaCount"          = 1
      "tag"                   = var.app_version
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}

# 모든 서브넷에 AWS Load Balancer Controller가 요구하는 태그 부여
# resource "aws_ec2_tag" "common" {
#   for_each = toset(concat(var.public_subnets, var.private_subnets))

#   resource_id = each.key
#   key         = "kubernetes.io/cluster/${var.cluster_name}"
#   value       = "owned"
#     lifecycle {
#     ignore_changes = [
#       resource_id
#     ]
#   }
# }

# # Scheme가 Internet-facing인 ELB를 생성할 서브넷에 요구되는 태그 부여
# resource "aws_ec2_tag" "public" {
#   for_each = toset(var.public_subnets)

#   resource_id = each.key
#   key         = "kubernetes.io/role/elb"
#   value       = "1"
#     lifecycle {
#     ignore_changes = [
#       resource_id
#     ]
#   }
# }

# # Scheme가 Internal인 ELB를 생성할 서브넷에 요구되는 태그 부여
# resource "aws_ec2_tag" "private" {
#   for_each = toset(var.private_subnets)

#   resource_id = each.key
#   key         = "kubernetes.io/role/internal-elb"
#   value       = "1"

#     lifecycle {
#     ignore_changes = [
#       resource_id
#     ]
#   }
# }