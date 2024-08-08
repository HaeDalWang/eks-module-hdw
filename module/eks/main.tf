# Terraform을 실행하는 AWS 자격 증명
data "aws_caller_identity" "current" {}

# AWS 자격증명에 부여된 세션 정보
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

# EKS 생성에 필요한 IAM 역할
resource "aws_iam_role" "eks_service_role" {
  name = "${var.cluster_name}-eks-cluster-service-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# EKS 생성에 필요한 IAM 권한
resource "aws_iam_role_policy_attachment" "eks_service_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_service_role.name
}

# EKS 클러스터(EKS 엔드포인트와 연동된 ENI)에 부여할 보안그룹
resource "aws_security_group" "eks_security_group" {
  name        = "${var.cluster_name}-eks-cluster"
  description = "control communications from the Kubernetes control plane to compute resources in your account."
  vpc_id      = var.vpc_id
}

# EKS 클러스터
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_service_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.vpc_subnet_ids
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    security_group_ids      = [aws_security_group.eks_security_group.id]
  }

  access_config {
    authentication_mode = var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.eks_service_role
  ]
}

# IRSA 생성에 필요한 ODIC 제공자
data "tls_certificate" "this" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = merge(
    { "eks:cluster-name" = "${var.cluster_name}" },
    var.tags
  )
}

## Fargate 실행에 필요한 권한 생성
resource "aws_iam_role" "fargate_profile" {
  count = var.fargate_profiles != null && var.fargate_profiles != {} ? 1 : 0

  name = "eks-fargate-profile-execution"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy" {
  count = var.fargate_profiles != null && var.fargate_profiles != {} ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_profile[0].name
}

## Fargate Profile 구성
resource "aws_eks_fargate_profile" "this" {
  for_each = var.fargate_profiles
  cluster_name           = var.cluster_name
  fargate_profile_name   = each.key

  pod_execution_role_arn = aws_iam_role.fargate_profile[0].arn
  subnet_ids             = var.vpc_subnet_ids

  dynamic "selector" {
    for_each = each.value.selectors
    content{
      namespace = selector.value.namespace
      labels    = lookup(selector.value, "labels", {})
    }
  }
}
