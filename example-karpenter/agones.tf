# Agones를 설치할 네임스페이스
resource "kubernetes_namespace" "agones" {
  metadata {
    name = "agones-system"
  }
}

# GameServer을 배포할 네임스페이스
# 사용하지 않을 경우 default에 배포해야됩니다 + helmvalue에 gameservers.namespace 항목을 삭제합니다
resource "kubernetes_namespace" "game" {
  metadata {
    name = "game"
  }
}

## Agones 설치
resource "helm_release" "agones" {
  name             = "agones"
  repository       = "https://agones.dev/chart/stable"
  chart            = "agones"
  version          = var.agones_chart_version
  namespace        = kubernetes_namespace.agones.metadata[0].name
  timeout          = 420

  values = [
    templatefile("${path.module}/helm-values/agones.yaml", {
    })
  ]

  depends_on = [ kubectl_manifest.karpenter_default_nodepool ]
}