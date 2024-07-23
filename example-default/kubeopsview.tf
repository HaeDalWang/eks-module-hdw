# resource "helm_release" "kubeopsview" {
#   chart = "kube-ops-view"
#   name = "kube-ops-view"
#   repository = "https://charts.christianhuth.de"
#   namespace = "kube-system"
#   version = "3.5.0"

#   set {
#     name = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name = "serviceAccount.name"
#     value = "kube-ops-view"
#   }

#   set {
#     name = "ingress.className"
#     value = "alb"
#   }

#   set {
#     name = "ingress.enabled"
#     value = "true"
#   }

#   set {
#     name = "ingress.host"
#     value = "*"
#   }

#   set {
#     name = "ingress.paths[0].path"
#     value = "/"
#   }

#   set {
#     name = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/scheme"
#     value = "internet-facing"
#   }

#   set {
#     name = "ingress.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
#     value = "ip"
#   }

# }