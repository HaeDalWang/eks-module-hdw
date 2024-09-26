# # GitLab
# resource "helm_release" "gitlab" {
#   name       = "gitlab"
#   repository = "http://charts.gitlab.io/"
#   chart      = "gitlab"
#   version    = var.gitlab_chart_version

#   values = [
#     templatefile("${path.module}/helm-values/gitlab.yaml", {
#       domain = aws_route53_zone.this.name
#     })
#   ]
# }