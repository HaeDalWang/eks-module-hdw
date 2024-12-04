# locals {
#   apps = [
#     "project-sample-python"
#   ]
# }

# # GitLab을 설치할 네임스페이스
# resource "kubernetes_namespace" "gitlab" {
#   metadata {
#     name = "gitlab"
#   }
# }

# # GitLab
# resource "helm_release" "gitlab" {
#   name       = "gitlab"
#   repository = "https://charts.gitlab.io"
#   chart      = "gitlab"
#   version    = var.gitlab_chart_version
#   namespace  = kubernetes_namespace.gitlab.metadata[0].name
#   timeout    = 900

#   values = [
#     templatefile("${path.module}/helm-values/gitlab.yaml", {
#       domain = "${data.aws_route53_zone.seungdobae.name}"
#     })
#   ]

#   depends_on = [
#     kubectl_manifest.karpenter_default_nodepool,
#     kubernetes_annotations.default_storageclass,
#     module.aws_load_balancer_controller
#   ]
# }

# # # ECR 리포지토리
# # module "ecr" {
# #   source  = "terraform-aws-modules/ecr/aws"
# #   version = "2.3.0"

# #   for_each = toset(local.apps)

# #   repository_name = each.key

# #   # ECR 생애주기 정책 생성 유무
# #   create_lifecycle_policy = false`
# # }

# # Jenkins를 배포할 네임 스페이스
# resource "kubernetes_namespace" "jenkins" {
#   metadata {
#     name = "jenkins"
#   }
# }

# # 젠킨스 Pod에 부여할 IRSA 생성하고 ECR에 이미지를 쓸수 있는 권한 부여
# module "jenkins_sa" {
#   source = "../module/eks-irsa"

#   name                 = "jenkins"
#   namespace            = "jenkins"
#   cluster_name         = module.eks.cluster_id
#   cluster_oidc_issuer  = module.eks.cluster_oidc_provider
#   create_iam_role_only = true
#   managed_policy_arns  = ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"]
# }

# # Jenkins
# resource "helm_release" "jenkins" {
#   name       = "jenkins"
#   repository = "https://charts.jenkins.io"
#   chart      = "jenkins"
#   version    = var.jenkins_chart_version
#   namespace  = kubernetes_namespace.jenkins.metadata[0].name
#   timeout    = 900

#   values = [
#     templatefile("${path.module}/helm-values/jenkins.yaml", {
#       password = "admin1234"
#       sa-arn   = module.jenkins_sa.role_arn
#     })
#   ]

#   depends_on = [
#     kubectl_manifest.karpenter_default_nodepool,
#     kubernetes_annotations.default_storageclass,
#     module.aws_load_balancer_controller
#   ]
# }