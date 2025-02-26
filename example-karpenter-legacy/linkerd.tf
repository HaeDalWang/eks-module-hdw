# # Linkerd 배포할 네임 스페이스
# resource "kubernetes_namespace" "linkerd" {
#   metadata {
#     name = "linkerd"
#   }
# }

# # Linkerd 배포
# resource "helm_release" "linkerd_crd" {
#   name       = "linkerd-crds"
#   repository = "https://helm.linkerd.io/edge"
#   chart      = "linkerd-crds"
#   version    = "2025.1.2"
#   namespace  = kubernetes_namespace.linkerd.metadata[0].name

#   depends_on = [kubernetes_namespace.linkerd]
# }

# resource "helm_release" "linkerd" {
#   name       = "linkerd"
#   repository = "https://helm.linkerd.io/edge"
#   chart      = "linkerd-control-plane"
#   version    = "2025.1.2"
#   namespace  = kubernetes_namespace.linkerd.metadata[0].name

#   values = [
#     templatefile("${path.module}/helm-values/linkerd.yaml", {
#       # values 적용 시 인증서의 드려쓰기를 그대로 넣기위해 몇칸띄우는지 정의
#       ca_cert     = replace(file("${path.module}/cert/ca.crt"), "/\n/", "\n  "),
#       issuer_cert = replace(file("${path.module}/cert/issuer.crt"), "/\n/", "\n        "),
#       issuer_key  = replace(file("${path.module}/cert/issuer.key"), "/\n/", "\n        ")
#     })
#   ]

#   depends_on = [helm_release.linkerd_crd]
# }

# # Linkerd viz(대시보드 확장)배포
# resource "helm_release" "linkerd_viz" {
#   name       = "linkerd-viz"
#   repository = "https://helm.linkerd.io/edge"
#   chart      = "linkerd-viz"
#   version    = "2025.1.2"
#   namespace  = kubernetes_namespace.linkerd.metadata[0].name

#   values = [
#     templatefile("${path.module}/helm-values/linkerd-viz.yaml", {})
#   ]

#   depends_on = [helm_release.linkerd]
# }
# # Linkerd viz ingress
# # viz helm chart안에 ingress가 없음
# resource "kubectl_manifest" "web_ingress" {
#   yaml_body = <<-YAML
# apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   name: web-ingress
#   namespace: linkerd
#   annotations:
#     kubernetes.io/ingress.class: alb
#     alb.ingress.kubernetes.io/scheme: internet-facing
#     alb.ingress.kubernetes.io/target-type: ip
#     alb.ingress.kubernetes.io/ssl-redirect: "443"
#     alb.ingress.kubernetes.io/backend-protocol: "HTTP"
#     alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
# spec:
#   rules:
#     - host: linkerd.seungdobae.com
#       http:
#         paths:
#           - path: "/"
#             pathType: Prefix
#             backend:
#               service:
#                 name: web
#                 port:
#                   number: 8084
#   YAML
# }
