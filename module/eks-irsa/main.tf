# Terraform을 실행한 AWS 자격증명 정보 받아오기
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

/* IAM 정책 생성
   신뢰관계에서 아래에서 생성되는 ServiceAccount에서만 해당 역할을 수임할수 있도록 설정 */
resource "aws_iam_policy" "this" {
  count       = var.policy_document != "" ? 1 : 0
  name_prefix = "${var.cluster_name}-${var.namespace}-${var.name}-"
  policy      = var.policy_document
}

# IAM 역할 생성
resource "aws_iam_role" "this" {
  name_prefix         = substr("${var.cluster_name}-${var.namespace}-${var.name}-", 0, 37)
  managed_policy_arns = var.policy_document != "" ? [aws_iam_policy.this[0].arn] : var.managed_policy_arns
  assume_role_policy  = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${local.account_id}:oidc-provider/${var.cluster_oidc_issuer}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.cluster_oidc_issuer}:aud": "sts.amazonaws.com",
          "${var.cluster_oidc_issuer}:sub": "system:serviceaccount:${var.namespace}:${var.name}"
        }
      }
    }
  ]
}
POLICY
}

/* 서비스 어카운트 생성
   Helm 차트 등을 통해서 이미 ServiceAccount가 생성되어 있는 경우에는 IAM 역할만 생성 */
resource "kubernetes_service_account" "this" {
  count = !var.create_iam_role_only ? 1 : 0

  metadata {
    name      = var.name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" : "arn:aws:iam::${local.account_id}:role/${aws_iam_role.this.name}"
    }
  }
}